FROM swift:5.9.0

# Install Deno
RUN apt-get -qq update \
  && apt-get -qq -y install curl zip unzip \
  && curl -fsSL https://deno.land/x/install/install.sh | sh \
  && apt-get -qq remove curl zip unzip \
  && apt-get -qq remove --purge -y curl zip unzip \
  && apt-get -qq -y autoremove \
  && apt-get -qq clean

WORKDIR /app

RUN echo 'int isatty(int fd) { return 1; }' | \
  clang -O2 -fpic -shared -ldl -o faketty.so -xc -
RUN strip faketty.so && chmod 400 faketty.so

ENV PATH "/root/.deno/bin:$PATH"

COPY deps.ts .
RUN deno cache --reload --unstable deps.ts

ADD . .
RUN deno cache --reload --unstable main.ts

EXPOSE 8000
CMD ["deno", "run", "--allow-env", "--allow-net", "--allow-run", "main.ts"]
