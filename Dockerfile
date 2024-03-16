FROM rust:1.67

WORKDIR /usr/src/rust-tester
COPY . .

RUN cargo install --path .

CMD ["cargo", "run"]