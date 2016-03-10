FROM ubuntu-debootstrap:14.04
COPY ./cedar-14-julia.sh /tmp/build.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/build.sh \
  && rm -rf /var/lib/apt/lists/*

# Internally, we arbitrarily use port 3000
ENV PORT 3000

# Create some needed directories
RUN mkdir -p /app/.profile.d
WORKDIR /app/user

# `init` is kept out of /app so it won't be duplicated on Heroku
# Heroku already has a mechanism for running .profile.d scripts,
# so this is just for local parity
COPY ./init /usr/bin/init

# install Julia
RUN wget https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.3-linux-x86_64.tar.gz && \
mkdir -p /app && \
tar xvf julia-0.4.3-linux-x86_64.tar.gz -C /app && \
ln -s /app/julia-a2f713dea5 /app/julia && \
rm julia-0.4.3-linux-x86_64.tar.gz && \
find /app/julia/bin -type f \
  -exec strip --strip-all '{}' ';' && \
find /app/julia/lib -type f \
  -exec strip --strip-debug '{}' ';'

ENV PATH $PATH:/app/julia/bin
ENV HOME /app
RUN cp /usr/lib/x86_64-linux-gnu/libnettle.so* /app/julia/lib && \
#rm /usr/lib/x86_64-linux-gnu/libnettle.so && \
export LD_LIBRARY_PATH=/app/.heroku/julia/lib && \
julia -e 'Pkg.add("IJulia")' && \
find /app/.julia/v0.4/Conda/deps/usr/bin/ -type f \
  -exec strip --strip-all '{}' ';' && \
find /app/.julia/v0.4/Conda/deps/usr/lib/ -type f \
    -exec strip --strip-debug '{}' ';' && \
mkdir -p /app/.jupyter/kernels && \
cp -r /app/.julia/v0.4/IJulia/deps/julia-0.4/ /app/.jupyter/kernels

#RUN echo "import Conda; Conda.SCRIPTDIR"|julia
RUN perl -pi -e 's#/usr/lib/x86_64-linux-gnu/libnettle.so#/app/julia/lib/libnettle.so#g' \
    /app/.julia/v0.4/Nettle/deps/deps.jl && \
(cd /app/.julia;tar zcf v0.4.tgz v0.4) && \
rm -rf /app/.julia/v0.4

COPY ./start_jupyter /app/user/
ADD ./jupyterconfig.py /app/user/
ENV LD_LIBRARY_PATH /app/julia/lib
