# Ceph调整nearfull ratio
## Set nearfull ratio
```sh
ceph pg set_nearfull_ratio 0.80
ceph tell mon.* injectargs '--mon-osd-nearfull-ratio 0.80'
ceph tell osd.* injectargs '--mon-osd-nearfull-ratio 0.80'
```
## Set full ratio
```sh
ceph pg set_full_ratio 0.85
ceph tell mon.* injectargs '--mon-osd-full-ratio 0.85'
ceph tell osd.* injectargs '--mon-osd-full-ratio 0.85'
```