FROM fishtownanalytics/dbt:1.2.0
WORKDIR /support
RUN mkdir /root/.dbt
COPY profiles.yml /root/.dbt
RUN mkdir /root/onboarding
WORKDIR /onboarding
COPY . .
EXPOSE 8080
ENTRYPOINT [ "bash"]
