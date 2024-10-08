#base frame of our container-image
FROM python:3.10-alpine

#directoty in the container that contains all files/assets of the project 
WORKDIR /app

#copies the files of the current folder from the host in the /app-directory of the container during build process 
COPY . $WORKDIR

#installs the dependencies for the app and that are saved in the requirements.txt
RUN python -m pip install -r requirements.txt

#opens container port 5000 for interaction
EXPOSE 5000

#command that runs automatically every time the container is started. the command *python babyshop_app/manage.py createsupe* is a custumized command that opens the script *createsupe.py*.
ENTRYPOINT ["/bin/sh", "-c", "python babyshop_app/manage.py migrate && python babyshop_app/manage.py createsupe && python babyshop_app/manage.py runserver 0.0.0.0:5000"]
