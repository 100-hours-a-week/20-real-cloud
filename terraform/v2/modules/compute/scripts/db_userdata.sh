#!/bin/bash
set -e

# 1. 기본 패키지 설치
yum update -y
yum install -y git awscli wget unzip

# 2. MySQL & Redis 설치
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum localinstall -y mysql80-community-release-el7-3.noarch.rpm
yum install -y mysql-community-server
amazon-linux-extras enable redis6
yum clean metadata
yum install -y redis

# 3. 서비스 시작
systemctl enable mysqld
systemctl start mysqld
systemctl enable redis
systemctl start redis

# 4. 비밀번호 SSM에서 가져오기
MYSQL_ROOT_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)
DB_USERNAME=$(aws ssm get-parameter --name "/config/prod/db_user" --with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/config/prod/db_passwd" --with-decryption --query "Parameter.Value" --output text)

# 5. MySQL 초기 비밀번호 변경
MYSQL_TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
mysql -u root -p"$MYSQL_TEMP_PASS" --connect-expired-password <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
EOF

# 6. DB 사용자 생성 및 권한 부여
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE USER IF NOT EXISTS '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USERNAME'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# 7. 최신 Dump 복원
S3_BUCKET="s3://ktb-ca-mvp-log/mysql-backup"
TMP_DIR="/tmp/mysql_restore"
mkdir -p $TMP_DIR
LATEST_DUMP=$(aws s3 ls $S3_BUCKET/ | sort | tail -n 1 | awk '{print $4}')
aws s3 cp "$S3_BUCKET/$LATEST_DUMP" "$TMP_DIR/latest_dump.sql"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" < "$TMP_DIR/latest_dump.sql"

# 8. 크론잡 스크립트 (Dump, 로그 업로드)
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