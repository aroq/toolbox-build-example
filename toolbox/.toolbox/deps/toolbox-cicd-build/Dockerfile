# Main stage
FROM aroq/toolbox

COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

RUN gem install --no-ri --no-rdoc etc && \
    gem install --no-ri --no-rdoc -v 0.0.107 docman

COPY rootfs/ /
RUN chown root:root /root/.ssh/config && chmod 600 /root/.ssh/config
