FROM smartc.azurecr.io/imageclassifierservice:0.2.5-arm32v7
# Base Image for Image Classifier Service IoT Edge on ARM

# Exchange the model
ADD /app/door/model.pb /app/model.pb
ADD /app/door/labels.txt /app/lables.txt

# Expose the port
EXPOSE 80

# Set the working directory
WORKDIR /app

# Run the flask server for the endpoints
CMD ["python3","app.py"]