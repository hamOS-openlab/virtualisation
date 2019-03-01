#!/bin/bash
#
# hamOS.fr
# Virtualisation QEMU
# v.0.1 @rems (thank for sharing with me )
# v.0.5 @sebh (28 feb 2019)
# CREATE VirtualMachine
echo -e "\033[32mhamOS.fr openLab-Virtualisation\033[0m"
qemudetection () {
which qemu-system-x86_64
if [ $? != 0 ]; then
echo -e "\033[31mQemu ne semble pas être installé sur votre système\033[0m"
exit 1
fi
}

vmnamequery () {
echo -e "\033[33mNOM de la VM que vous souhaitez créer (Sans espaces) ?\033[0m"
read name
echo -e "\033[32mNOM de la VM sera $name\033[0m"
}

hdsizequery () {
echo -e "\033[33mTAILLE disque (30G) (M pour Megaoctets, G pour Gigaoctets, T pour Teraoctets sans espaces) ?\033[0m"
read size
    if [ -z $size ]; then
    size=30G
    fi
echo -e "\033[32mLa taille du disque sera de $size\033[0m"
}

biosoruefivm () {
echo -e "\033[33mQuelle type de VM voulez vous ? BIOS (par défaut) ou UEFI :\033[0m"
read type
    if [ -z $type ]; then
        type=BIOS
    fi
    case $type in
        bios|BIOS)
        createvmbios
        echo -e "\033[32mLa machine sera configurée en mode $type\033[0m"
        ;;
        uefi|UEFI)
        createvmuefi
        echo -e "\033[32mLa machine sera configurée en mode $type\033[0m"
        ;;
        *)
        echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
        exit 1
        ;;
    esac
}

createvmuefi () {
if [ ! -f /usr/share/OVMF/OVMF_VARS.fd ]; then
        echo -e "\033[31mVeuillez installer le paquet OVMF ou apparenté\033[0m"
        exit 1
fi
if [ ! -d $name ]; then
        mkdir -pv $name
    else
        echo -e "\033[31mLe dossier de la VM existe\033[0m"
        exit 1
fi
if [ ! -f $name/$name.qcow2 ]; then
        echo -e "\033[32mqemu-img create -f qcow2 $name/$name.qcow2 $size\033[0m"
        qemu-img create -f qcow2 $name/$name.qcow2 $size
        cp -v /usr/share/OVMF/OVMF_VARS.fd $name/OVMF_VARS_$name.uefi
    else
    echo -e "\033[31mLe disque de la VM existe, pas de création\033[0m"
        exit 1
fi
}

createvmbios () {
if [ ! -d $name ]; then
        mkdir -pv $name
    else
        echo -e "\033[31mLe dossier de la VM existe\033[0m"
        exit 1
fi
if [ ! -f $name/$name.qcow2 ]; then
        echo -e "\033[32mqemu-img create -f qcow2 $name/$name.qcow2 $size\033[0m"
        qemu-img create -f qcow2 $name/$name.qcow2 $size
        cp -v /usr/share/OVMF/OVMF_VARS.fd $name/OVMF_VARS_$name.bios
    else
        echo -e "\033[31mLe disque de la VM existe, pas de création\033[0m"
        exit 1
fi
}

main () {
qemudetection
vmnamequery
hdsizequery
biosoruefivm
}
main "$@"