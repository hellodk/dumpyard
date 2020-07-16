import urllib2
import urllib
import pytesseract
import Image
opener = urllib2.build_opener()
IMAGE_URL = "http://www.nccptrai.gov.in/nccpregistry/NccpTraiLogin/imagegenerator"
response = opener.open(IMAGE_URL)
img = open("crack.jpg", "w")
img.write(response.read())
img.close()
cap = pytesseract.image_to_string(Image.open("crack.jpg"))
print cap
