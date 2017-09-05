FROM alpine:3.4
CMD ["echo", "hello-in-images-in-CMD"]
ENTRYPOINT ["echo", "hello-in-images-ENTRYPOINT"]
