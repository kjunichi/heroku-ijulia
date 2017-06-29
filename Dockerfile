FROM ubuntu:16.04

RUN apt-get update \
  && apt-get upgrade -y --force-yes

RUN apt-get install -y --no-install-recommends ca-certificates \
  wget build-essential binutils nettle-dev

# Internally, we arbitrarily use port 3000
ENV PORT 3000

# Create some needed directories
WORKDIR /app/user

# install Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.0-linux-x86_64.tar.gz && \
mkdir -p /opt && \
tar xvf julia-0.6.0-linux-x86_64.tar.gz -C /opt && \
ln -s /opt/julia-* /opt/julia && \
rm julia-*-linux-x86_64.tar.gz 

ENV PATH $PATH:/opt/julia/bin
ENV HOME /app/user

RUN julia -e 'Pkg.add("IJulia")' && \
mkdir -p /app/user/.jupyter/kernels && \
cp -r /app/user/.julia/v*/IJulia/deps/julia-*/ /app/user/.jupyter/kernels 

COPY ./start_jupyter /app/user/
COPY ./InitJulia.ipynb /app/user/
COPY ./jupyterconfig.py /app/user/
ENV LD_LIBRARY_PATH /opt/julia/lib
CMD /app/user/start_jupyter
