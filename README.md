# Ubuntu on XPS 7590
How to fix some Ubuntu issues on XPS 7590

## Fix issues
### CPU power management
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

### Fast Suspend Battery Draining
1. Open a terminal window
2. Run the following commands:
    ```
    $ sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mem_sleep_default=deep/' /etc/default/grub
    $ update-grub

### Screen Brightness (OLED)
1. Copy `oled-brightness/oled-linux` folder in `/home/<your_name>/.config/`
2. Copy `oled-brightness/oled-linux.desktop` in `/home/<your_name>/.config/autostart/`
3. Reboot

## Extra
### Touchpad gestures
Installing [Fusuma](https://github.com/iberianpig/fusuma), a multitouch gesture recognizer. This gem makes your linux able to recognize swipes or pinchs and assign commands to them.
1. Grant permission to read the touchpad device

    **IMPORTANT**: You **MUST** be a member of the **INPUT** group to read touchpad by Fusuma.

    ```bash
    $ sudo gpasswd -a $USER input
    ```

    Then, You **MUST** **REBOOT** to assign this group.
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