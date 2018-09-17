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

## Content Descriptor
### 概念
* An OCI Image包含包含多个组件。
* 组件之间的引用格式为：content descriptor。
* 一个Content Descriptor表示目标content。
* Content Descriptor包含至少三部分：type of content，digest of content，byte-size of the raw content。
* Descriptors应该嵌入在其他的格式（Image Types）中，用来引用外部的content。
* 其他的格式（Image Types）应该使用Descriptors引用外部content。
### 属性
三个必需的属性：
* mediaType
* digest
* size
两个可选的属性：
* urls
* annotations
### 例子
```json
{
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "size": 7682,
  "digest": "sha256:5b0bcabd1ed22e9fb1310cf6c2dec7cdef19f0ad69efa1f392e94a4333501270"
}

{
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "size": 7682,
  "digest": "sha256:5b0bcabd1ed22e9fb1310cf6c2dec7cdef19f0ad69efa1f392e94a4333501270",
  "urls": [
    "https://example.com/example-manifest"
  ]
}
```
## Image Layout
### 三部分
* blobs
* oci-layout
* index.json
### BLOBS
* `blobs`的子目录为各个hash算法。比如sha256，sha512。
* `blobs/<alg>/<encoded>的内容必须和content descriptor中的`digest <alg>:<encoded>`相匹配。比如：blobs/sha256/da39a3ee5e6b4b0d3255bfef95601890afd80709的内容和descriptor中的digest sha256:da39a3ee5e6b4b0d3255bfef95601890afd80709完全匹配。
### OCI-LAYOUT
Image Type of OCI-Layout是：`application/vnd.oci.layout.header.v1+json`

```json
{
    "imageLayoutVersion": "1.0.0"
}
```
### INDEX.JSON
该文件是Image Layout中的references和descriptors中的入口。
该文件的格式为`application/vnd.oci.image.index.v1+json`

## OCI Image Index Specification
`application/vnd.oci.image.index.v1+json`。

Image Index指向具体的Image Manifests，是一个higher-levle manifest。
### 属性
* schemaVersion： 2
* mediaType
* manifests
    * mediaType：一般由2个选择：
        1. `application/vnd.oci.image.manifest.v1+json`
        2. `application/vnd.oci.image.index.v1+json` (nested index)
    * platform
        * architecture 
        * os
        * os.version
        * os.features：字符串数组
        * variant
        * features
* annotations
### 例子
```json
{
  "schemaVersion": 2,
  "manifests": [
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 7143,
      "digest": "sha256:e692418e4cbaf90ca69d05a66403747baa33ee08806650b51fab815ad7fc331f",
      "platform": {
        "architecture": "ppc64le",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 7682,
      "digest": "sha256:5b0bcabd1ed22e9fb1310cf6c2dec7cdef19f0ad69efa1f392e94a4333501270",
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    }
  ],
  "annotations": {
    "com.example.key1": "value1",
    "com.example.key2": "value2"
  }
}
```
## OCI Image Manifest Specification
`application/vnd.oci.image.manifest.v1+json`。

### 概念
`Image Manifest`：描述了一个针对具体arch和os的container image，包括两大部分：一个configuration和多个layers。
* configuration由`application/vnd.oci.image.config.v1+json`描述
* layers的格式较多，包括：
    * application/vnd.oci.image.layer.v1.tar
    * application/vnd.oci.image.layer.v1.tar+gzip
    * application/vnd.oci.image.layer.nondistributable.v1.tar
    * application/vnd.oci.image.layer.nondistributable.v1.tar+gzip

### 属性
* schemaVersion
* mediaType
* config
    * mediaType
    * size
    * digest
* layers
    [
        {
            * mediaType
            * size
            * digest
        }
    ]
* annotations
### 例子
```json
{
  "schemaVersion": 2,
  "config": {
    "mediaType": "application/vnd.oci.image.config.v1+json",
    "size": 7023,
    "digest": "sha256:b5b2b2c507a0944348e0303114d8d93aaaa081732b86451d9bce1f432a537bc7"
  },
  "layers": [
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "size": 32654,
      "digest": "sha256:9834876dcfb05cb167a5c24953eba58c4ac89b1adf57f28f2f9d09af107ee8f0"
    },
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "size": 16724,
      "digest": "sha256:3c3a4604a545cdc127456d94e421cd355bca5b528f4a9c1905b15da2eb4a4c6b"
    },
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "size": 73109,
      "digest": "sha256:ec4b8955958665577945c89419d1af06b5f7636b4ac3da7f12184802ad867736"
    }
  ],
  "annotations": {
    "com.example.key1": "value1",
    "com.example.key2": "value2"
  }
}
```
## OCI Image Configuration
`application/vnd.oci.image.config.v1+json`。

An OCI Image is an ordered collection of root filesystem changes and the corresponding execution parameters for use within a container runtime. 

### ImageID
Each image's ID is given by the SHA256 hash of its configuration JSON. 

## Layers Types
* application/vnd.oci.image.layer.v1.tar
* application/vnd.oci.image.layer.v1.tar+gzip
* application/vnd.oci.image.layer.nondistributable.v1.tar
* application/vnd.oci.image.layer.nondistributable.v1.tar+gzip



