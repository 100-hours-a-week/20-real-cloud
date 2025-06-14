#!/bin/bash
set -e

# 1. 기본 패키지 설치
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt upgrade -y
apt install -y git awscli wget unzip cron mysql-server redis-server gzip

# 2. 서비스 시작 및 활성화
systemctl enable mysql
systemctl start mysql
systemctl enable redis-server
systemctl start redis-server

# 3. 비밀번호 SSM에서 가져오기
MYSQL_ROOT_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)
DB_USERNAME=$(aws ssm get-parameter --name "/config/prod/db_user" --with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)

# 4. MySQL 루트 비밀번호 설정
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

# 5. DB 사용자 생성 및 권한 부여
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE USER IF NOT EXISTS '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USERNAME'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# 6. 최신 압축된 Dump 복원 (.sql.gz)
S3_BUCKET="s3://ktb-ca-mvp-log/mysql-backups"
TMP_DIR="/tmp/mysql_restore"
mkdir -p $TMP_DIR
LATEST_DUMP=$(aws s3 ls $S3_BUCKET/ | sort | tail -n 1 | awk '{print $4}')
aws s3 cp "$S3_BUCKET/$LATEST_DUMP" "$TMP_DIR/latest_dump.sql.gz"
gunzip -c "$TMP_DIR/latest_dump.sql.gz" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"

# 7. 백업 및 로그 업로드용 크론잡 스크립트 생성
CRON_SCRIPT="/usr/local/bin/mysql_s3_backup.sh"
LOG_SCRIPT="/usr/local/bin/mysql_log_upload.sh"

cat > $CRON_SCRIPT <<'EOS'
#!/bin/bash
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DUMP_FILE="/tmp/mysql_backup_$DATE.sql"
GZ_FILE="${DUMP_FILE}.gz"
BUCKET="s3://ktb-ca-mvp-log/mysql-backups"

MYSQL_ROOT_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)

mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --all-databases > "$DUMP_FILE"
gzip "$DUMP_FILE"
aws s3 cp "$GZ_FILE" "$BUCKET/"
rm -f "$GZ_FILE"
EOS
chmod +x $CRON_SCRIPT

cat > $LOG_SCRIPT <<'EOS'
#!/bin/bash
LOG_SRC="/var/log/mysql/error.log"
BUCKET="s3://ktb-ca-mvp-log/mysql-logs"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

aws s3 cp "$LOG_SRC" "$BUCKET/db-log/mysqld-$DATE.log"
EOS
chmod +x $LOG_SCRIPT

# 8. 크론잡 등록 (중복 방지)
(crontab -l 2>/dev/null | grep -v "$CRON_SCRIPT"; echo "0 2 * * * $CRON_SCRIPT") | crontab -
(crontab -l 2>/dev/null | grep -v "$LOG_SCRIPT"; echo "30 2 * * * $LOG_SCRIPT") | crontab -
