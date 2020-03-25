FROM python:3.7.7

# ARG AWS_ACCESS_KEY_ID
# ARG AWS_SECRET_ACCESS_KEY
# ARG AWS_REGION=ap-southeast-2

# RUN pip install --no-cache-dir awscli && \
#    mkdir /root/.aws

COPY . /api
WORKDIR /api

# RUN aws s3 sync s3://aiyi.fuzzysearch /api/model/

# RUN ls -lR /api/model

RUN pip install -r requirements.txt

ENTRYPOINT ["python"]

CMD ["api.py"]
