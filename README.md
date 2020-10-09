# Ubuntu on XPS 7590
How to fix some Ubuntu issues on XPS 7590

## CPU power management
Without further configuration the CPU will run quite hot and will quickly drain the battery. 
We are going to Install:
1.  [powertop](https://01.org/powertop/overview)
2.  [thermald](https://01.org/linux-thermal-daemon)
3.  [TLP](https://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html#installation)

### How to do:
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

## Suspend Draining battery fast
By default, the very inefficient `s2idle` suspend variant is incorrectly selected. This is probably due to the BIOS. The much more efficient `deep` variant should be selected instead.

### How to do:
1. Open a terminal window
2. Run the following commands:
    ```
    $ sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mem_sleep_default=deep/' /etc/default/grub
    $ update-grub

## Screen Brightness (OLED)
When pressing the function keys to change the screen brightness, you will see the Ubuntu brightness icon and its brightness bar changing. However, the brightness of the screen will not change. Apparently, Ubuntu tries to change the background brightness of the screen. Since OLED screens do not have a background illumination, nothing happens.
This is undesirable. Not only will the screen often be too bright, it will also age the display faster. 

### How to do:
1. Copy `oled-brightness/oled-linux` folder in `/home/<your_name>/.config/`
2. Copy `oled-brightness/oled-linux.desktop` in `/home/<your_name>/.config/autostart/`
3. Reboot

## Touchpad gestures
Installing [Fusuma](https://github.com/iberianpig/fusuma), a multitouch gesture recognizer. This gem makes your linux able to recognize swipes or pinchs and assign commands to them.

### How to do:
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