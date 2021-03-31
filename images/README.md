# How to use?

* Download the sample data and copy the following JSON files to this folder:

```
page1.json    page100.json  page1100.json page1300.json page1500.json page1700.json page1900.json page2000.json page400.json  page600.json  page800.json
page10.json   page1000.json page1200.json page1400.json page1600.json page1800.json page200.json  page300.json  page500.json  page700.json  page900.json
```

Alternatively, just copy the sample images directly to this folder!

* Run the AI server!

Please take a look at `../README_DOCKER.md` for further details!

* Process the images!

Edit the file `process_images.bash` and set the `IMG_SERVER_HOST` constant. This needs to be a host name which is resovlable from within the AI server's container.

```
./process_images.bash
```

* Test with a photo from your webcam!

Edit the file `test_image.bash` and set your test image by setting the `TEST_IMG` constant. Mine is `http://$IMG_SERVER_HOST:$IMG_SERVER_PORT/test_marshall.jpg`.

```
./test_image.bash
```


