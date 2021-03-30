# How to build?

The Dockerfile follows the instructions in the README.md file, whereby it was necessary to build each of the modules as part of the creation of the Docker image.

Here the steps how to build the Docker image 'similar-images':

1. Clone the repo: `git clone git@github.com:redislabs-training/similar-images.git`
2. Change the directory to the the just cloned repo: `cd similar-images`
3. Run a Docker build: `docker build -t similar-images .`
4. Start the image: `docker run similar-images`
