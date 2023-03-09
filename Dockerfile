ARG BASE_IMAGE=ubuntu:latest
FROM $BASE_IMAGE

RUN mkdir /i686-elf-tools
COPY ./i686-elf-tools.sh /i686-elf-tools/i686-elf-tools.sh
RUN apt-get update && apt-get install -y \
    git \
    wget \
    sudo \
    make \
    lsb-release \
  && chmod +x /i686-elf-tools/i686-elf-tools.sh \
  && /i686-elf-tools/i686-elf-tools.sh env -parallel \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /opt/mxe/.ccache \
  && rm -rf /opt/mxe/pkg

ENTRYPOINT ["/i686-elf-tools/i686-elf-tools.sh"]
