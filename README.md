To install the required R libraries:

```
R <depends.R --no-save
```

To access US ACS Census data, create a file `census-api-key.R` with the contents:

```
census_api_key("...")
```

Then, to generate the image set:

```
R <us-cumulative-percap.R --no-save
```

And finally, to create an mp4 from the frames (`imageio` and `imageio-ffmpeg` are required):

```
python makemp4.py us-cumulative-percap output.mp4
```