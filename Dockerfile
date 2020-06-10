FROM scratch

COPY ./fileserver /bin/fileserver
COPY ./dist /public
ENTRYPOINT [ "/bin/fileserver" ]
CMD [ "-path","/public" ]