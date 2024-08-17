FROM debian:bookworm

RUN apt-get update && apt-get -y install git curl unzip

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /home/codespace
WORKDIR /home/codespace

ENV PUB_CACHE=/home/codespace/.pub_cache
ENV PATH="/home/codespace/flutter/bin:$PATH"

RUN git clone https://github.com/flutter/flutter && \
    /home/codespace/flutter/bin/flutter config --enable-web



COPY . /dartServer 
RUN mkdir build
RUN dart compile exe /dartServer/bin/server -o /dartServer/dartserv

# FROM debian:buster-slim
# COPY --from=builder /dartServer/build /bin
CMD ["/dartServer/dartserv"]
