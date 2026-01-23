FROM python:3.14-rc-slim-bookworm
USER root
RUN apt-get update && apt-get install socat -y
RUN pip install pycryptodome

COPY chall.py .
ENV FLAG="SECCON{Listening_to_the_murmuring_waves_and_the_capricious_passing_rain_it_feels_like_a_gentle_dream}"

CMD ["socat", "TCP-L:5000,fork,reuseaddr", "EXEC:'python3 chall.py'"]