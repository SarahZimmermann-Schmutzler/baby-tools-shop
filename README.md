# Containerize an application on a VM using the example of a web shop: BabyStore

### TECHNOLOGIES

#### Web Shop
- Python 3.9
- Django 4.0.2
- Venv

#### Containerization
- Docker

### BabyStore - The Baby Tools Shop

After your setup the application is a Python and Django based web shop, that offers products (baby tools) to potential buyers. It includes a detail-view of the products, an register and login option for the buyers. 

You get the empty web shop frame which you can fill - with help of the django admin panel - with categories and matching products that then appeares in the shop.

#### Shop Example

##### Homepage
<img alt="" src="https://github.com/SarahZimmermann-Schmutzler/baby-tools-shop/blob/main/project_images/homepage.png"></img>

##### Category "Baby Care" and Logged User
<img alt="" src="https://github.com/SarahZimmermann-Schmutzler/baby-tools-shop/blob/main/project_images/cat_logged.png"></img>

##### Product Detail View
<img alt="" src="https://github.com/SarahZimmermann-Schmutzler/baby-tools-shop/blob/main/project_images/details.png"></img>

##### Register Page
<img alt="" src="https://github.com/SarahZimmermann-Schmutzler/baby-tools-shop/blob/main/project_images/register.png"></img>

##### Login Page
<img alt="" src="https://github.com/SarahZimmermann-Schmutzler/baby-tools-shop/blob/main/project_images/login.png"></img>


### What is Containerization?

The shop is ready and pretty and you further developed the application. But now what? 

One way to release the shop is the method of **CONTAINERIZATION**. There you put the application with its dependencies in a closed environment called container. The container can be made to run on any server, for example a virtual machine. One provider of this containerization process is **Docker**.


### Usage

#### Get the shop up and running

1. Fork the baby-tools-shop in your github namespace.  

2. Clone the project to your server. You can clone it either to the server (f.e. virtual environment )you want to run the application later or first to your pc / laptop for an easier workaround with a code editor.

3. Open the module *babyshop*, create and open the virtual environment:  
    `sudo apt install python3.10-venv`  
    `python3 -m venv env`  
    `source env/bin/activate`

4. Install the *requirements.txt*:
    `pip install -r requirements.txt`

5. Take a look at the `settings.py` and add your VMs IP-Adress to the `Allowed Hosts`.

6. Don't forget to save your addings on github.You can use the up.bat file:
  - up + name_of_change_without_question_marks  
    `up new allowed host`

7. Try to start the application:
  - For running BabyStore on your local server (pc / laptop):`python manage.py runserver`
Just follow the link then. It opens in your web server on localhost 8000.

  - For starting the application from your virtual environment: `python manage.py runserver 0.0.0.0:8025`
The app is now running on IP-Adress-Of-Your-VM:8025. You can use an other port than 8025 of course.

  - It works (yeah!!!) and you see an empty store. Congrats you are awesome!

  - Starting failed (ohhh!!!) and you see an error. You are still awesome! Only a few dependencies are missing. Just intsall them, the console shows what is missing. 


#### Put the shop in a container and show it to the world

1. Install **Docker** globally on your server:
  - Ubuntu:  
    `sudo apt install docker.io`

  - Did it work?  
  package installed at: `cat /var/log/dpkg.log | grep "install" | grep docker`  
  OR  
  check docker status: `sudo systemctl status docker`

2. Write a **Dockerfile**. It's a so called conatiner-image, and thus the base of the container:  
``` Dockerfile
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
```

3. Add the *supe-script* that is used in the **Dockerfile** to create a superuser non-interactively so you can interact with the django admin panel when the shop app is running. Put it in: `baby-tools-shop/products/management/commands/createsupe.py`:  

    ```python
    from django.core.management.base import BaseCommand
    from django.contrib.auth.models import User
    import dotenv
    import os

    class Command(BaseCommand):
        help = 'Create a superuser non-interactively'

        def handle(self, *args, **options):
            # load .env-file
            dotenv.load_dotenv()

            # load values from .env-file
            username = os.environ.get('SUPERUSER_USERNAME')
            email = os.environ.get('SUPERUSER_EMAIL')
            password = os.environ.get('SUPERUSER_PASSWORD')

            if not username or not email or not password:
                self.stdout.write(self.style.ERROR('Superuser credentials are missing in the .env file.'))
                return

            if not User.objects.filter(username=username).exists():
             User.objects.create_superuser(username=username, email=email, password=password)
                self.stdout.write(self.style.SUCCESS(f'Superuser "{username}" created successfully!'))
            else:
                self.stdout.write(self.style.WARNING(f'Superuser "{username}" already exists.'))
    ```
4. Work with **dotenv** to keep sensitive data secret:  
  `pip install python-dotenv`  
  `pip freeze > requirements.txt`  
  - Then create a dotenv-file `.env` in the main directory where the key-value-pairs are saved. Do not push it on github! Just write a new .env on the server you run the containerized application.

5. Add an dockerignore-file `.dockerignore` to the main directory that contains the directories that should not be copied to the container.  

```
  .gitignore
  .git/
  __pycache__/
```

6. App works? `Dockerfile`, `.dockerignore` and `.env` are ready? Then let's build the **docker-image**:  
  `docker build -t name-of-your-image -f Dockerfile .`
  - `-t name-of-your-image`: the tag (name) of the container-image
  - `-f Dockerfile .`: base of the docker-image is the Dockerfile from the current directory

7. Did it work properly? Do a test run and start the container that is removed after closing:  
  `docker run -it --rm -p 8025:5000 name-of-your-image`  
  - `-it`: starts an interactive session between shell and container, so we can communicate with it
  - `--rm`: removes container after closing it
  - `-p 8025:5000`: portbinding our_server:container
  - `name-of-your-image`: reference to the container-image that we named 'demo-app'

8. Did it work? Let's find out with the help of the web browser:  
  - Run container from local server (pc / laptop): localhost:8025
  - Run container from VM: IP_Address_VM:8025  
  If there is an error regarding the templates, check the `settings.py` and adjust the path.

9. Everything fine? Then let's start the container that keeps the database after restart and that restars automatically after an error that closes the application.  
  `docker run -d --name name-of-your-container -p 8025:5000 -v /home/usr/docker/app-data:/data --restart unless-stopped name-of-your-image`  
  - `-d`: detached mode; container runs in background
  - `--name name-of-your-container`: you can name your container
  - `-v /home/usr/docker/app-data:/data`: you can save the data from the database on your host server; otherwise it will be deleted after stopping the container; /directory on your host server where you store the data:/directory in the container where the data is saved
  - `--restart unless-stopped`: container restarts always automatically except it is stopped manually

10. Did it work?  
  - Have a look which containers are running:  
    `docker ps`  
  - Open the admin panel of the application in the web browser and add some data.
  - Stop and start the container manually, the data should be there:  
    `docker stop name-of-your-container`  
    `docker start name-of-your-container`  
  

### Checklist
Here is a checklist that shows some important points for the containerization process:  
<a href="https://github.com/SarahZimmermann-Schmutzler/baby-tools-shop/blob/main/Checkliste_Baby_Tools_Shop.pdf">Checklist</a>


<!-- ### Hints

This section will cover some hot tips when trying to interacting with this repository:

- Settings & Configuration for Django can be found in `babyshop_app/babyshop/settings.py`
- Routing: Routing information, such as available routes can be found from any `urls.py` file in `babyshop_app` and corresponding subdirectories

### Photos

##### Home Page with login

<img alt="" src="https://github.com/MET-DEV/Django-E-Commerce/blob/master/project_images/capture_20220323080815407.jpg"></img>
##### Home Page with filter
<img alt="" src="https://github.com/MET-DEV/Django-E-Commerce/blob/master/project_images/capture_20220323080840305.jpg"></img>
##### Product Detail Page
<img alt="" src="https://github.com/MET-DEV/Django-E-Commerce/blob/master/project_images/capture_20220323080934541.jpg"></img>

##### Home Page with no login
<img alt="" src="https://github.com/MET-DEV/Django-E-Commerce/blob/master/project_images/capture_20220323080953570.jpg"></img>


##### Register Page

<img alt="" src="https://github.com/MET-DEV/Django-E-Commerce/blob/master/project_images/capture_20220323081016022.jpg"></img>


##### Login Page

<img alt="" src="https://github.com/MET-DEV/Django-E-Commerce/blob/master/project_images/capture_20220323081044867.jpg"></img> -->
