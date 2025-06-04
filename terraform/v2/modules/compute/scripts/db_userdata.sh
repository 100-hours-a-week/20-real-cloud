#!/bin/bash
set -e

# 1. 기본 패키지 설치
dnf update -y
dnf install -y git awscli wget unzip

# 2. MySQL 8.0 설치 (기본 저장소)
dnf install -y mysql-server

# 3. Redis 설치 (redis6은 amazon-linux-extras 없음)
dnf install -y redis

# 4. 서비스 시작
systemctl enable mysqld
systemctl start mysqld
systemctl enable redis
systemctl start redis

# 5. 비밀번호 SSM에서 가져오기
MYSQL_ROOT_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)
DB_USERNAME=$(aws ssm get-parameter --name "/config/prod/db_user" --with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)

# 6. MySQL 초기 비밀번호 설정
# AL2023의 mysqld는 기본 설정으로 비밀번호 없음 (확인 필요 시 /var/log/mysqld.log)
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
EOF

# 7. DB 사용자 생성 및 권한 부여
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE USER IF NOT EXISTS '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USERNAME'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# 8. 최신 Dump 복원
S3_BUCKET="s3://ktb-ca-mvp-log/mysql-backup"
TMP_DIR="/tmp/mysql_restore"
mkdir -p $TMP_DIR
LATEST_DUMP=$(aws s3 ls $S3_BUCKET/ | sort | tail -n 1 | awk '{print $4}')
aws s3 cp "$S3_BUCKET/$LATEST_DUMP" "$TMP_DIR/latest_dump.sql"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" < "$TMP_DIR/latest_dump.sql"

# 9. 크론잡 스크립트
CRON_SCRIPT="/usr/local/bin/mysql_s3_backup.sh"
LOG_SCRIPT="/usr/local/bin/mysql_log_upload.sh"

cat > $CRON_SCRIPT <<'EOS'
#!/bin/bash
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DUMP_FILE="/tmp/mysql_backup_$DATE.sql"
BUCKET="s3://ktb-ca-mvp-log/mysql-backups"

MYSQL_ROOT_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)

mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --all-databases > $DUMP_FILE
aws s3 cp $DUMP_FILE "$BUCKET/"
rm -f $DUMP_FILE
EOS
chmod +x $CRON_SCRIPT

cat > $LOG_SCRIPT <<'EOS'
#!/bin/bash
LOG_SRC="/var/log/mysqld.log"
BUCKET="s3://ktb-ca-mvp-log/mysql-logs"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

aws s3 cp $LOG_SRC "$BUCKET/db-log/mysqld-$DATE.log"
EOS
chmod +x $LOG_SCRIPT

(crontab -l 2>/dev/null; echo "0 2 * * * $CRON_SCRIPT") | crontab -
(crontab -l 2>/dev/null; echo "30 2 * * * $LOG_SCRIPT") | crontab -