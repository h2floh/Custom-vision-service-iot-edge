ARG REPOSITORY

FROM $REPOSITORY/imageclassifierservice-arm:base
# Base Image for Image Classifier Service IoT Edge on ARM

# Exchange the model
ADD /app/door/model.pb /app/model.pb
ADD /app/door/labels.txt /app/labels.txt

# Expose the port
EXPOSE 80

# Set the working directory
WORKDIR /app

# Run the flask server for the endpoints
CMD python -u app.py