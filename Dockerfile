FROM --platform=amd64 node:18 as frontend

# Makes a directory for our frontend folder commands
WORKDIR /frontend

# Copy the package.json into the docker image
COPY ./frontend/package.json .

# Installs all deps (note, we have package-lock in ignore)
RUN npm install
# Copy the frontend folder (local) into our current WORKDIR (/frontend)
COPY ./frontend .
# Run the build command
RUN npm run build


# Start with the python:3.9 image
FROM --platform=amd64 python:3.9

# Set the directory for upcoming commands to /var/www
WORKDIR /var/www

# You can leave this hardcoded wso you dont have to fill it in later
ENV FLASK_APP=app

# FLASK_ENV -> Tell flask to use the production server
ENV FLASK_ENV=production

# SQLALCHEMY_ECHO -> Used to output our sql to the terminals
ENV SQLALCHEMY_ECHO=True

# Fill this in on the docker environments and on render for prod
ARG SECRET_KEY
ENV SECRET_KEY=${SECRET_KEY}

# Fill this in on the docker environments and on render for prod
ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}

# Fill this in on the docker environments and on render for prod
ARG SCHEMA
ENV SCHEMA=${SCHEMA}


# Install postgres into the docker environment
RUN pip install psycopg2[binary]

# Copy the requirements.txt -> used to get deps for the python backend
COPY ./backend/requirements.txt ./backend/
# Install the python deps: Note. We can use pip in docker
RUN pip install -r ./backend/requirements.txt

# Copy the bin folder -> used for boot up commands
COPY ./bin ./bin
# Copy the backend folder - changed, but not as often as frontend
COPY ./backend ./backend
# Copy the frontend folder from the stage. Only copys the production folder (dist)
# Keep this under the backend folder copy because frontend gets changed more often
COPY --from=frontend /frontend/dist ./frontend/dist


# Docker/Render will run our application on their devices' port 5000
EXPOSE 5000

# This will run all our build commands

# start the flask server
CMD ["bash", "./bin/start.sh"]


