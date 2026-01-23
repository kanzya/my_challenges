FROM sagemath/sagemath@sha256:4f5589eb6c565949a006f8665de2876b8414410daf5ac554f4434a15d4f3d528

USER root
RUN apt-get update && apt-get install -y socat hashcash 

WORKDIR /app

COPY --chmod=755 chall.sage .
COPY --chmod=755 run.sh .
ENV FLAG="SECCON{You_have_made_your_wish_so_you_have_got_to_make_it_true}"
RUN sage --pip install pycryptodome

CMD ["socat","TCP-L:5000,fork,reuseaddr","EXEC:timeout --kill-after=5m 30m /app/run.sh"]
