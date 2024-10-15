FROM amazon/aws-cli:latest

RUN yum update -y && yum install -y curl git

COPY . .

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]