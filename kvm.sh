#!/bin/bash
#
# hamOS.fr
# Virtualisation QEMU
# v.0.1 @rems (thank for sharing with me )
# v.0.5 @sebh (28 feb 2019)
# START VirtualMachine
nbcoresquery () {
echo -e "\033[33mCombien de coeurs utilisera la VM ? (par défaut 2)\033[0m"
read coresquery
if [ -z $coresquery ]; then
	cores=2
	echo -e "\033[32mLe nombre de coeurs alloués à la VM sera de $cores\033[0m"
else
    cores=$coresquery
    echo -e "\033[32mLe nombre de coeurs alloués à la VM sera de $cores\033[0m"
fi
}

cpuquery () {
echo -e "\033[33mQuel type de CPU ? (host par défaut, kvm32, kvm64, base)\033[0m"
read cpuquery
if [ -z $cpuquery ]; then
    cpuquery=host
fi
case $cpuquery in
    host)
		    cpu=host
	        echo -e "\033[32mLe CPU hote sera utilisé\033[0m"
        ;;
    kvm32)
		    cpu=kvm32
			echo -e "\033[32mLe CPU utilisé sera $cpu\033[0m"
        ;;
    kvm64)
		    cpu=kvm64
	        echo -e "\033[32mLe CPU utilisé sera $cpu\033[0m"
        ;;
    base)
		    cpu=base
	        echo -e "\033[32mLe CPU utilisé sera $cpu\033[0m"
        ;;
    exit)
		    exit 1
	    ;;
    *)
		    echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
		    unset cpuquery
		    cpuquery
	    ;;
    esac
}

tabletquery () {
echo -e "\033[33mBesoin du support pointeur tablette ? (oui par défaut ou non)\033[0m"
read tabletquery
if [ -z $tabletquery ]; then
    tabletquery=O
fi
case $tabletquery in
        O|o|oui)
	        tablet="-device usb-tablet"
	        echo -e "\033[32mLe support pointeur tablette est activé\033[0m"
        ;;
	        N|n|non)
	        tablet=""
	        echo -e "\033[32mLe support pointeur tablette est inactif\033[0m"
        ;;
        exit)
	        exit 1
        ;;
        *)
	        echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
	        unset tabletquery
	        tabletquery
        ;;
    esac
}

soundhwquery () {
case $displayquery in
	    vnc|spice)
	    sndhw=""
	    echo -e "\033[32mPas de carte son\033[0m"
	;;
	    *)
        echo -e "\033[33mQuel type de carte son ? (ac97 par défaut, hda, sb16, rien)\033[0m"
        read sndhwquery
        if [ -z $sndhwquery ]; then
            sndhwquery=ac97
        fi
        case $sndhwquery in
            ac97)
    	        sndhw="-soundhw ac97"
    	        echo -e "\033[32mLa carte son sera $sndhwquery\033[0m"
            ;;
            hda)
    	        sndhw="-soundhw hda"
    	        echo -e "\033[32mLa carte son sera $sndhwquery\033[0m"
            ;;
            sb16)
    	        sndhw="-soundhw sb16"
    	        echo -e "\033[32mLa carte son sera $sndhwquery\033[0m"
            ;;
            rien)
    	        sndhw=""
    	        echo -e "\033[32mPas de carte son\033[0m"
            ;;
            exit)
            exit 1
            ;;
            *)
            echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
            unset sndhwquery
            soundhwquery
            ;;
        esac
    ;;
    esac
}

vgaquery () {
echo -e "\033[33mQuel type de carte graphique ? (virtio par défaut, std, cirrus, qxl)\033[0m"
read vgaquery
if [ -z $vgaquery ]; then
    vgaquery=VIRTIO
fi
    case $vgaquery in
        virtio|Virtio|VIRTIO)
    	    vga=virtio
        	echo -e "\033[32mLa carte graphique sera $vga\033[0m"
        	echo -e "\033[33mSouhaitez vous le support OpenGL, oui ou non (par défaut)\033[0m"
        	read glquery
        	if [ -z $glquery ]; then
        	    glquery=non
        	fi
            case $glquery in
                O|o|oui)
                gl="-display sdl,gl=on"
                echo -e "\033[32mL'accelération OpenGL est activé dans la VM\033[0m"
                ;;
                N|n|non)
                gl=""
                echo -e "\033[32mPas d'accelération openGL de la VM\033[0m"
                ;;
                *)
                echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
                vgaquery
            esac
        ;;
        std)
        	vga=std
        	echo -e "\033[32mLa carte graphique sera $vga\033[0m"
        ;;
        cirrus)
        	vga=cirrus
        	echo -e "\033[32mLa carte graphique sera $vga\033[0m"
        ;;
        qxl)
        	vga=qxl
        	echo -e "\033[32mLa carte graphique sera $vga\033[0m"
        	display="-spice port=5900,addr=127.0.0.1,disable-ticketing"
        	echo -e "\033[32mLa sortie de la VM sera en SPICE\033[0m"
        ;;
        exit)
        	exit 1
        ;;
        *)
        	echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
        	unset vgaquery
        	vgaquery
        ;;
    esac
}
displayquery () {
if [ $vga == qxl ]; then
    echo -e ""
else
    echo -e "\033[33mQuel type de sortie graphique ? (local par défaut, vnc, spice)\033[0m"
    read displayquery
    if [ -z $displayquery ]; then
        displayquery=local
    fi
    case $displayquery in
        local)
        	display=""
        	echo -e "\033[32mLa VM s'affichera sur votre écran\033[0m"
        ;;
        vnc)
        	if [ -n "$gl" ]; then
        	echo -e "\033[31mL'accelération OpenGL n'est pas disponible en VNC\033[0m"
        	gl="" 
        	fi
        	display="-display vnc=0:0 -k fr"
        	echo -e "\033[32mLa sortie de la VM sera en VNC localhost:0, clavier en FR\033[0m"
        ;;
        spice)
        	display="-spice port=5900,addr=127.0.0.1,disable-ticketing"
        	echo -e "\033[32mLa sortie de la VM sera en SPICE, localhost:5900 \033[0m"
        ;;
        exit)
        	exit 1
        ;;
        *)
  			echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
      		displayquery
    ;;
    esac
fi
}
netquery () {
echo -e "\033[33mQuel type de carte réseau ? (virtio par défaut, e1000, rtl8139\033[0m"
read netquery
if [ -z $netquery ]; then
    netquery=VIRTIO
fi
    case $netquery in
        virtio|Virtio|VIRTIO)
        	net=virtio-net
        	echo -e "\033[32mLe réseau aura $net comme périphérique\033[0m"
        ;;
        e1000)
        	net=e1000
        	echo -e "\033[32mLe réseau aura $net comme périphérique\033[0m"
        ;;
        rtl8139|8139)
        	net=rtl8139
        	echo -e "\033[32mLe réseau aura $net comme périphérique\033[0m"
        ;;
        exit)
        	exit 1
        ;;
        *)
        	echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
        	netquery
        ;;
    esac
}

memquery () {
echo -e "\033[33mQuelle quantité de mémoire souhaitée pour la VM ? (Défaut 2G)\033[0m"
read memquery
if [ -z $memquery ]; then
    mem=2G
    echo -e "\033[32mLa VM utilisera $mem de RAM\033[0m"
else
    mem=$memquery
	echo -e "\033[32mLa VM utilisera $mem de RAM\033[0m"
fi
}
checkvm () {
if [ ! -d $name ]; then
	echo -e "\033[31mle dossier de la VM n'existe pas, veuillez utiliser le script createvm.sh pour le créer\033[0m"
	exit 1
fi
if [ ! -f $name/$name.qcow2 ]; then
	echo -e "\033[31mle disque dur de la VM n'existe pas, veuillez utiliser le script createvm.sh pour le créer\033[0m"
	exit 1
else
	firstdrive="-drive file=$name/$name.qcow2"
	echo -e "\033[32mLe disque $name/$name.qcow2 sera utilisé pour la VM\033[0m"
fi
}

vmquery () {
ls
echo -e "\033[33mEntrez le nom de la VM que vous souhaitez exécuter\033[0m"
read name
echo -e "\033[32mLa VM $name sera démarrée\033[0m"
}
configorstart () {
if [ -f $name/$name.qemu ]; then
	startqemu
else
    iffirstdiskquery
	memquery
	cpuquery
	nbcoresquery
	netquery
	cdromquery
	vgaquery
	displayquery
	soundhwquery
	tabletquery
	biosoruefi
fi
}
iffirstdiskquery () {

echo -e "\033[33mQuelle interface pour le disque 1 ? (ide, par défaut ou virtio)\033[0m"
read ifquery
if [ -z $ifquery ]; then
    ifquery=ide
fi
    case $ifquery in
        ide|IDE)
            if="if=ide"
            echo -e "\033[32mL'interface disque sera IDE"
        ;;
        virtio|VIRTIO)
            if="if=virtio"
            echo -e "\033[32mL'interface disque sera VIRTIO"
        ;;
        exit)
            exit 1
        ;;
        *)
            echo -e "\033[31mLa réponse n'est pas correcte\033[0m"
            iffirstdiskquery
        ;;
    esac

}

cdromquery () {
if [ ! -d iso ]; then
	echo "\033[31mLe dossier iso n'existe pas, veuillez le créer et y mettre vos ISOS\033[0m"
	exit 1
fi
ls iso/
echo -e "\033[33mVoulez vous utiliser une ISO ? (rien si pas d'ISO)\033[0m"
read cdrom
if [ ! -z $cdrom ]; then
        if [ -f iso/$cdrom ]; then
            iso="-drive file=iso/$cdrom,media=cdrom,if=ide -boot menu=on"
            echo -e "\033[32mLe fichier ISO iso/$cdrom sera utilisé\033[0m"
        else
            echo "\033[31mLe fichier ISO n'existe pas\033[0m"
            unset cdrom
            cdromquery
        fi
else
        iso=""
        echo -e "\033[32mpas de CD-Rom\033[0m"
fi
}

biosoruefi () {
if [ -f "$name/OVMF_VARS_$name.uefi" ]; then
echo -e "Creation fichier config en UEFI"
createfileuefi
else
echo -e "Creation du fichier de config en BIOS"
createfilebios
fi
}

createfileuefi () {
if [ ! -f $name/$name.qemu ]; then
	echo "qemu-system-x86_64 -enable-kvm -M q35 -m $mem -cpu $cpu -smp cores=$cores -device $net,netdev=net0 -netdev user,id=net0 -device virtio-balloon -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd -drive if=pflash,format=raw,file=$name/OVMF_VARS_$name.uefi -drive file=$name/$name.qcow2,$if $iso -device virtio-vga,id=vga,max_hostmem=256000000 $sndhw -nodefaults $gl $display -device qemu-xhci -usb $tablet" > $name/$name.qemu

startqemu
else
	echo -e "La configuration de Qemu pour cette VM existe."
	startqemu
fi
}

createfilebios () {
if [ ! -f $name/$name.qemu ]; then
	echo "qemu-system-x86_64 -enable-kvm -M q35 -m $mem -cpu $cpu -smp cores=$cores -device $net,netdev=net0 -netdev user,id=net0 -device virtio-balloon $firstdrive,$if $iso $seconddrive -vga $vga $sndhw -nodefaults $gl $display -usb $tablet" > $name/$name.qemu
    startqemu
else
	echo -e "La configuration de Qemu pour cette VM existe."
	startqemu
fi
}

startqemu () {
cat $name/$name.qemu
sh $name/$name.qemu
}

main () {
vmquery
checkvm
configorstart
}

main "$@"
