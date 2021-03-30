# How to build?

The Dockerfile follows the instructions in the README.md file, whereby it was necessary to build each of the modules as part of the creation of the Docker image.

Here the steps how to build the Docker image 'similar-images':

1. Export your Github access token as environment variable: `export GH_USER=youruserhere;export GH_TOKEN=yourtokenhere`
2. Clone the repo: `git clone git@github.com:redislabs-training/similar-images.git`
3. Change the directory to the the just cloned repo: `cd similar-images`
4. Run a Docker build: `docker build --build-arg GH_USER --build-arg GH_TOKEN -t similar-images .`
5. Start the image: `docker run -p 5000:5000 similar-images`
6. Test it with a random image: http://localhost:5000/similar-skus?imageUrl=https://drive.google.com/uc?id=1s21uQxKQjB7CuU-svW2P0eYKsHgO6hfR