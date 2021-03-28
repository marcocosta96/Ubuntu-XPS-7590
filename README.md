# **Ubuntu on XPS 7590**
How to fix some Ubuntu 20.04 issues on XPS 7590 and some useful tutorials.

## **Fix issues**
### **CPU power management**
1. Open a terminal
2. Run the following command:
    ```
    $ sudo apt install -y powertop thermald tlp
    ```
3. Run 
    ```
    $ sudo powertop
    ``` 
4. Click `Shift+TAB` to navigate to Tunables
5. Click `Enter` on the `Bad` to change to `Good`
6. Run below command to create a service file called `powertop.service` at `/etc/systemd/system/`
    ```
    cat << EOF | sudo tee /etc/systemd/system/powertop.service
    [Unit]
    Description=PowerTOP auto tune

    [Service]
    Type=idle
    Environment="TERM=dumb"
    ExecStart=/usr/sbin/powertop --auto-tune

    [Install]
    WantedBy=multi-user.target
    EOF
    ```
7. Run below command to enable the service at boot time
    ```
    $ sudo systemctl daemon-reload
    $ sudo systemctl enable powertop.service
    ```
8. Run the following command:
    ```
    $ sudo tlp start
    ```

### **Fast Suspend Battery Draining**
1. Open a terminal window
2. Run the following commands:
    ```
    $ sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mem_sleep_default=deep/' /etc/default/grub
    $ update-grub

### **Screen Brightness (OLED)**
1. Install *inotifywait* with the command `sudo apt install inotify-tools`
2. Copy `oled-brightness/oled-linux/oled-linux.sh` in `/home/<your_name>/.config/oled-linux/`
3. Copy `oled-brightness/oled-linux.desktop` in `/home/<your_name>/.config/autostart/`
4. Reboot

    Go [here](https://github.com/lawleagle/oled-linux) for more informations.

### **4K Scale**
Some applications may not be scaled correctly for 4k resolution. To solve this problem you have to modify the `<app_name>.desktop` file adding `--force-device-scale-factor=2.0` in the `Exec=` line. The file is in the following path:
- `/usr/share/applications/<app_name>.desktop` if the application was installed with apt
- `/var/lib/snapd/desktop/applications/<app_name>.desktop` if the application was installed with snap

### **Wrong Time in Dual Boot with Windows 10**
Start `cmd` with Administrator Prompts, then digit:
```
$ Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_QWORD /d 1
```

## **Extra**
### **Install NVidia drivers**
#### Remove Previous Installations
In case you installed NVIDIA driver before, it’s very recommended, must remove previous installation.
```
$ sudo apt-get purge nvidia*
```
#### Download the NVIDIA Driver
Latest NVIDIA drivers can be download from their [official website](https://www.nvidia.com/object/unix.html)
#### Install the Dependencies
Other library as dependencies is required if we want to install NVIDIA driver via runfile. We need to install this dependencies first.
```
$ sudo apt-get install build-essential gcc-multilib dkms
```
#### Blacklist the Nouveau Driver
Edit `/etc/modprobe.d/blacklist-nouveau.conf`
```
$ sudo nano /etc/modprobe.d/blacklist-nouveau.conf
```
Add the following lines:
```
blacklist nouveau
options nouveau modeset=0
```
Then run the following commands:
```
$ sudo update-initramfs -u
$ sudo reboot
```
#### Stop gdm Service
After reboot/restart, open console from login page (ctrl+alt+f2). and stop the gdm service using this command:
```
$ sudo systemctl stop gdm
```
#### Run the Installer
Enter the directory where you saved the downloaded NVIDIA driver installer, and run this commands:
```
$ chmod +x NVIDIA-Linux-x86_64-xxx.xx.run
$ sudo ./NVIDIA-Linux-x86_64-xxx.xx.run --dkms -s
```
where xxx.xx is the downloaded version (ex: NVIDIA-Linux-x86_64-460.67.run). -s is for silent installation, and --dkms is used for register dkms module into the kernel. 

Finally reboot the machine.

### **Install Cuda 11.0**
#### Download files
Download files from [here](https://drive.google.com/drive/folders/1-oFp9BJNyLkr7iAc1EKn4slokbADCwIW?usp=sharing)
#### Install Cuda 11.0
Enter the directory where you saved the downloaded files, and install CUDA 11.0 with the following commands:
```
$ chmod +x cuda_11.0.3_450.51.06_linux.run
$ sudo ./cuda_11.0.3_450.51.06_linux.run
```
#### Install CuDNN and TensorRT libraries
In the same directory, run the following command:
```
$ sudo dpkg -i libcudnn* nv-*
```
#### Edit .bashrc
Finally edit the `~/.bashrc` file adding the following lines:
```
# CUDA
CUDA_version=11.0
if [ -d "/usr/local/cuda-${CUDA_version}/bin/" ]; then
    export PATH=/usr/local/cuda-${CUDA_version}/bin${PATH:+:${PATH}}
    export LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_version}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-${CUDA_version}/extras/CUPTI/lib64
fi
```
Reboot your pc.

### **Check Temperatures**
We’re going to use a GUI tool, *Psensor*, that allows you to monitor hardware temperature on Linux.
Before you install *Psensor*, you need to install and configure *lm-sensors*, a command-line utility for hardware monitoring. If you want to measure hard disk temperature, you need to install *hddtemp* as well. To install these tools, run the following command in a terminal:
```
$ sudo apt install lm-sensors hddtemp
```
Then start the detection of your hardware sensors:
```
$ sudo sensors-detect
```
To make sure that it works, run the command below:
```
$ sensors
```
If everything seems alright, proceed with the installation of Psensor by using the command below:
```
$ sudo apt install psensor
```
Once installed, run the application by looking for it in the Unity Dash. On the first run, you should configure which stats you want to collect with Psensor.

### **Set Up a Python Virtual Environment**
```
$ mkdir ~/.virtualenvs
$ sudo apt install python3-pip
$ pip3 install virtualenv
$ pip3 install virtualenvwrapper
```
Then edit the `~/.bashrc` file adding the following lines:
```
#Virtualenvwrapper settings:
export WORKON_HOME=$HOME/.virtualenvs
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
. /home/<user_name>/.local/bin/virtualenvwrapper.sh
export PATH=/home/<user_name>/.local/bin${PATH:+:${PATH}}
```
changing *<user_name>* with your name.

Finally launch the command 
```
$ source ~/.bashrc
```
Usage:
- Create virtual environment:
```
$ mkvirtualenv name_of_your_env
```
- Activate virtual environment:
```
$ workon name_of_your_env
```
- Delete virtual environment:
```
$ rmvirtualenv name_of_your_env
```
- Show available virtual environment:
```
$ workon
```
or
```
$ lsvirtualenv
```
- Copy existing virtual environment to a new virtual environment:
```
$ cpvirtualenv old_virtual_env new_virtual_env
```


### **Touchpad gestures**
Installing [Fusuma](https://github.com/iberianpig/fusuma), a multitouch gesture recognizer. This gem makes your linux able to recognize swipes or pinchs and assign commands to them.
1. Grant permission to read the touchpad device

    **IMPORTANT**: You **MUST** be a member of the **INPUT** group to read touchpad by Fusuma.

    ```bash
    $ sudo gpasswd -a $USER input
    ```

    Then, You **MUST REBOOT** to assign this group.
    This process is needed to run fusuma without sudo.

2. Install libinput-tools

    You need `libinput` release 1.0 or later.

    ```bash
    $ sudo apt-get install libinput-tools
    ```

3. Install Ruby

    Fusuma runs in Ruby, so you must install it first.

    ```bash
    $ sudo apt-get install ruby
    ```

4. Install Fusuma

    ```bash
    $ sudo gem install fusuma
    ```

5. Install xdotool (optional)

    For sending shortcuts:

    ```bash
    $ sudo apt-get install xdotool
    ```

6. Add fusuma in autostart using `sudo fusuma -d`, name and description is up to you

    #### Touchpad not working in GNOME

    Ensure the touchpad events are being sent to the GNOME desktop by running the following command:

    ```bash
    $ gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
    ```

    #### Usage

    ```bash
    $ fusuma
    ```

    #### Update

    ```bash
    $ sudo gem update fusuma
    ```

    #### Customize Gesture Mapping

    You can customize the settings for gestures to put and edit `~/.config/fusuma/config.yml`.  
    **NOTE: You will need to create the `~/.config/fusuma` directory if it doesn't exist yet.**

    ```bash
    $ mkdir -p ~/.config/fusuma        # create config directory
    $ nano ~/.config/fusuma/config.yml # edit config file.
    ```

    You can simply copy the file `touchpad-gestures/config.yml` in `~/.config/fusuma/config.yml`.

### **Change GDM Background (Login Image)**
The script `change-gdm-background` automates the process of setting an image in the GNOME Display Manager 3 background which comes by default with Ubuntu version 20.04 Focal Fossa.
```
$ sudo apt install libglib2.0-dev-bin
$ chmod +x change-gdm-background
$ sudo ./change-gdm-background /path/to/image
```
Go [here](https://github.com/thiggy01/change-gdm-background) for more informations.

### **Add a New Notification Sound**
First we need our sound: `stereo`, `.wav` or `.ogg`, sample rate of `44100 Hz`.

If you like, move it to the default folder for system sounds `/usr/share/sounds/`, but having it somewhere else may work.

Now we edit a config file, (you can replace gedit for another text editor: vim, emacs, nano, kate, etc...)
```
$ sudo gedit /usr/share/gnome-control-center/sounds/gnome-sounds-default.xml
```
Go to the end of the text, and after the `</sounds>` tag add this:
```
<sound deleted="false">
  <name>Name</name>
  <filename>/path/to/your/sound.ogg</filename>
</sound>
```
All that’s left is to open Preferences > Sound (or gnome-volume-control at the command line) and select the new entry in the list of possible alert sounds.

### **GRUB Customizer**
Install with the command:
```
$ sudo apt install grub-customizer
```

### [**GRUB2 Themes**](https://github.com/vinceliuice/grub2-themes)
### [**Customizations**](https://www.gnome-look.org/browse/cat/)
### [**Mount Partition at Startup**](https://www.fosslinux.com/4216/how-to-automount-hard-disk-partitions-in-ubuntu.htm)
### [**Face Unlock**](https://itsfoss.com/face-unlock-ubuntu/)
### [**Docker**](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)
### [**Scrcpy (Control Android Devices)**](https://www.linuxuprising.com/2019/03/control-android-devices-from-your.html)
### [**OpenFortiGUI**](https://github.com/theinvisible/openfortigui)
