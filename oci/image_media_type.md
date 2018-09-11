# OCI Image Media Types
## Image Media Types简介
* application/vnd.oci.descriptor.v1+json                        Content Descriptor
* application/vnd.oci.layout.header.v1+json                     OCI Layout
* application/vnd.oci.image.index.v1+json                       Image Index
* application/vnd.oci.image.manifest.v1+json                    Image Manifest
* application/vnd.oci.image.config.v1+json                      Image Config
* application/vnd.oci.image.layer.v1.tar                        "Layer", as a tar archive
* application/vnd.oci.image.layer.v1.tar+gzip                   "Layer", as a tar archive compressed with gzip
* application/vnd.oci.image.layer.nondistributable.v1.tar       "Layer", as a tar archive with distribution restrictions
* application/vnd.oci.image.layer.nondistributable.v1.tar+gzip  "Layer", as a tar archive with distribution restrictions compressed with gzip

## 各Media Types之间关系
以上各个Image Type之间的关系如下图所示：
![](pics/media-types.png)