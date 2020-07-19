FROM gelbpunkt/python:gcc10

WORKDIR /build

ENV MAKEFLAGS "-j 8"

COPY 0001-Patch-677-ugly.patch /tmp/
COPY 0001-Support-orjson.patch /tmp/
COPY 0002-Support-orjson.patch /tmp/

RUN set -ex && \
    apk upgrade --no-cache && \
    apk add --no-cache --virtual .build-deps git gcc libgcc g++ musl-dev linux-headers make automake libtool m4 autoconf curl libffi-dev && \
    curl -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --profile minimal -y && \
    source $HOME/.cargo/env && \
    pip install maturin && \
    git config --global user.name "Jens Reidel" && \
    git config --global user.email "jens@troet.org" && \
    pip install -U git+https://github.com/pypa/wheel && \
    git clone https://github.com/ijl/orjson && \
    cd orjson && \
    rustup override set nightly-2020-06-01 && \
    rustup toolchain list && \
    maturin build --no-sdist --release --strip --interpreter python3 --manylinux off && \
    cd .. && \
    git clone https://github.com/amitdev/lru-dict && \
    cd lru-dict && \
    pip wheel . && \
    cd .. && \
    git clone https://github.com/astanin/python-tabulate && \
    cd python-tabulate && \
    pip wheel . && \
    cd .. && \
    git clone https://github.com/iomintz/import-expression-parser && \
    cd import-expression-parser && \
    pip wheel . && \
    cd .. && \
    git clone https://github.com/niklasf/python-chess && \
    cd python-chess && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/cython/cython && \
    cd cython && \
    pip wheel . && \
    pip install *.whl && \
    CYTHON_VERSION=$(pip show cython | grep "Version" | cut -d' ' -f 2) && \
    cd .. && \
    git clone https://github.com/MagicStack/asyncpg && \
    cd asyncpg && \
    git submodule update --init --recursive && \
    sed -i "s:0.29.20:$CYTHON_VERSION:g" setup.py && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/MagicStack/uvloop && \
    cd uvloop && \
    git submodule update --init --recursive && \
    git pull origin pull/337/merge --no-edit && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/aiohttp && \
    cd aiohttp && \
    git submodule update --init --recursive && \
    git pull origin pull/4483/merge --no-edit && \
    echo "cython==$CYTHON_VERSION" > requirements/cython.txt && \
    make cythonize && \
    pip wheel .[speedups] && \
    pip install *.whl && \
    TIMEOUT_VERSION=$(pip show async_timeout | grep "Version" | cut -d' ' -f 2) && \
    cd .. && \
    git clone https://github.com/aio-libs/aioredis && \
    cd aioredis && \
    sed -i "s:async-timeout:async-timeout==$TIMEOUT_VERSION:g" setup.py && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/giampaolo/psutil && \
    cd psutil && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/scrapinghub/dateparser && \
    cd dateparser && \
    git pull origin pull/531/merge --no-edit && \
    git pull origin pull/562/merge --no-edit && \
    git pull origin pull/477/merge --no-edit -s recursive -X ours && \
    git am -3 /tmp/0001-Patch-677-ugly.patch && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone --single-branch -b sharding-rework https://github.com/Rapptz/discord.py && \
    cd discord.py && \
    curl https://github.com/Rapptz/discord.py/compare/master...khazhyk:rfc-param-default.patch -L -o param-default.patch && \
    git am -3 param-default.patch && \
    curl https://github.com/Rapptz/discord.py/compare/master...bryanforbes:typings.patch -L -o typings.patch && \
    #git am -3 typings.patch && \
    git am -3 /tmp/0001-Support-orjson.patch && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/Rapptz/discord-ext-menus && \
    cd discord-ext-menus && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/Wavelink && \
    cd Wavelink && \
    git checkout patched-2 && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/aiowiki && \
    cd aiowiki && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/getsentry/sentry-python && \
    cd sentry-python && \
    git am -3 /tmp/0002-Support-orjson.patch && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://git.travitia.xyz/Adrian/fantasy-names && \
    cd fantasy-names && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/nir0s/distro && \
    cd distro && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/dabeaz/ply && \
    cd ply && \
    echo -e "from distutils.core import setup\nfrom Cython.Build import cythonize\nsetup(name=\"ply\", ext_modules=cythonize('ply/*.py'))" > setup.py && \
    sed -i 's/f = sys._getframe(levels)/f = sys._getframe()/' ply/lex.py && \
    sed -i 's/f = sys._getframe(levels)/f = sys._getframe()/' ply/yacc.py && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/jmoiron/humanize && \
    cd humanize && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/hellysmile/contextvars_executor && \
    cd contextvars_executor && \
    pip wheel . && \
    pip install *.whl && \
    cd ..

# allow for build caching
RUN mkdir /wheels && \
    find . -name \*.whl -exec cp {} /wheels \;

CMD sleep 20
