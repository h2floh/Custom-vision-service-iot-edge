ARG REPOSITORY

FROM $REPOSITORY/imageclassifierservice-arm:base
# Base Image for Image Classifier Service IoT Edge on ARM

# Exchange the model
ADD /app/applesbananas/model.pb /app/model.pb
ADD /app/applesbananas/labels.txt /app/labels.txt

# Expose the port
EXPOSE 80

# Set the working directory
WORKDIR /app

# Run the flask server for the endpoints
CMD python -u app.py