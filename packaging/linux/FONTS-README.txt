LeoMoon ParsiNegar system fonts

This archive contains the optional LMN compatibility and LMU Unicode fonts. It is intended for advanced Linux users who do not use the Ubuntu font package. The AppImage does not install these fonts system-wide.

For a system-wide installation, extract this archive, open a terminal inside the leomoon-parsinegar-fonts directory, and run:

    sudo install -d /usr/local/share/fonts/leomoon-parsinegar
    sudo install -m 644 ./*.ttf /usr/local/share/fonts/leomoon-parsinegar/
    sudo fc-cache -f

To uninstall, remove only the fonts you installed in /usr/local/share/fonts/leomoon-parsinegar and run sudo fc-cache -f again. If fonts with the same names are already installed, check for duplicates before copying them.
