FROM smartc.azurecr.io/imageclassifierservice-arm:base
# Base Image for Image Classifier Service IoT Edge on ARM

# Exchange the model
ADD /app/fire/model.pb /app/model.pb
ADD /app/fire/labels.txt /app/labels.txt

# Expose the port
EXPOSE 80

# Set the working directory
WORKDIR /app

# Run the flask server for the endpoints
CMD ["python3","app.py"]