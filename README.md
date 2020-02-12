# Dockerfiles

## Lazbuild for continuous integration

It's based on CentOS 7 and OpenSuse 15.1, both using FreePascal 3.0.4 as a compiler.
##### Only OpenSuse images support compile softwares for desktops (GUI). The main purpose of CentOS images is build daemons(services) softwre only.

What a OpenSuse image can do for you:
* Build CLI programs;
* Build GUI programs;
* Build for Windows or Linux, both x86 or x86_64 support;
* Use any Lazarus version that use FreePascal 3.0.4 as a default compiler;

What a CentOS image can do for you:
* Build CLI programs only;
* Build for Windows or Linux, both x86 or x86_64 support;
* Use any Lazarus version that use FreePascal 3.0.4 as a default compiler;

Arguments:
* TZ: TimeZone (Default: America/Sao_Paulo);
* DirSrc: Path to FreePascal and Lazarus sources (Default: ./sources);
* LazSrc: Name of Lazarus source file (Default: lazarus-1.8.4.tar.gz);

## Steps
* Download all sources in a directory:
```
# Make a directory first
mkdir -p $HOME/docker/beloved_directory

# Then download the sources
curl -L 'https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20x86_64%20RPM/Lazarus%201.8.4/fpc-3.0.4-1.x86_64.rpm'\
     -o $HOMe/docker/beloved_directory/fpc-3.0.4-1.x86_64.rpm
     
curl -L 'https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20x86_64%20RPM/Lazarus%201.8.4/fpc-src-3.0.4-1.x86_64.rpm'\
     -o $HOME/docker/beloved_directory/fpc-src-3.0.4-1.x86_64.rpm

curl -L 'https://sourceforge.net/projects/lazarus/files/Lazarus%20Zip%20_%20GZip/Lazarus%202.0.4/lazarus-2.0.4.tar.gz'\
     -o $HOME/docker/beloved_directory/lazarus-2.0.4.tar.gz
```
* Copy a configuration xml file into created directory:
```
cp $HOME/git-repo/lazbuild/fpc-3.0.4_based/environmentoptions.xml $HOME/docker/beloved_directory
```
* Build the image:
```
cd $HOME/docker/
docker image build \
  -t mylazbuild:1.0 \
  -f $HOME/git-repo/fpc-3.0.4_based/centos.dockerfile \
  --build-arg LazSrc=lazarus-2.0.4.tar.gz \
  --build-arg TZ=Antarctica/Palmer .
  ```
## Dockins: Jenkins + Docker client (Docker-in-Docker)
To build this image you only need to run this command:
```
docker image build \
  -t mydockins:1.0 \ 
  -f dockins/Dockerfile .
```
