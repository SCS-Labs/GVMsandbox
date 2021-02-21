# GVM Sandbox
Working on a new GVM Docker Container

**View Other Branches for Examples**

## TO-DO
- Add `open_scanner_protocol_daemon` to Dockerfile
- Add `gvm_tools_version` to Dockerfile
- Add `python_gvm_version` to Dockerfile
- Get add ssh for scanner so [baseenv.sh](/modules/base/baseenv.sh)
    - Remove username and password option for scanner 

## Thinking About
- Thinking about separating gvm components from Dockerfile and make them into separate scripts.
- Thinking about add `SRC_PATH` variable that can work in `/src` and build in by using `${SRC_PATH}`





## NOTE:
`ospd_openvas` is taken care of on [openVAS/install-pkgs.sh](/modules/openvas/install-pkgs.sh)



## Checkout New Branch for developing

**Checkout Blank Repo**

```shell
git checkout blankrepo
```

**Checkout New Branch for Development**

```shell
git checkout -b ver#
```


