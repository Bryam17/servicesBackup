#!/bin/bash

helpPanel(){

	echo -e "\n\t\t\t-----------------------------------------"
	echo -e "\t\t\t|Panel de ayuda de la herramienta backup|"
	echo -e "\t\t\t-----------------------------------------\n"
	echo -e "\t[*] Funcionamiento de la herramienta: \n"
	echo -e "\t    [>] ./backup.sh [hostname]"
	echo -e "\t    [>] Ejemplo: ./backup.sh mysql apache2 dns"
	echo -e "\t    [>] Se pueden proporcionar todos los parametros o algunos de ellos."
	echo -e "\t    [>] Si no se pasan parametros, se tomaran todos los parametros en cuenta.\n"
	echo -e "\t[*] Parametros validos: \n"
	echo -e "\t    [>] mysql"
	echo -e "\t    [>] apache2"
	echo -e "\t    [>] dns\n"

}

mysqlBackup(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh mysql bash -c "'

		#ifconfig | grep "inet" | head -n1 | tr -s '[:blank:]'
		#echo ""
		rm -rf mysql*
		#Backup de todas las bases de datos
		mysqldump -u root --password=123 --all-databases > backup.sql
		tar -czf mysql-$(date "+%d-%m-%Y_%H-%M").tar.gz backup.sql

	'"
	#si hay un copia de seguridad en el directorio lo elimina
	rm -rf $path/$dir/mysql*
	#Si el directorio ya existe solo copiara el archivo en el.
	if test -d $path/$dir; then
		scp -rp mysql:mysql* $path/$dir

	#Si no existe lo creara y copiara el archivo.
	else
		mkdir $path/$dir
		scp -rp mysql:mysql* $path/$dir
	fi

	echo ""
	echo "[*] Backup del servidor de base de datos realizado exitosamente."
	echo " >  Archivo copiado en $path/$dir/"
	echo ""

}

dnsBackup(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh dns bash -c "'
		#ifconfig | grep "inet" | head -n1 | tr -s '[:blank:]'
		rm -rf dns*
		#Backup del servicio bind9
		cd /etc/bind/ && tar -czf /root/dns-$(date "+%d-%m-%Y_%H-%M").tar.gz . 
	'"
	rm -rf $path/$dir/dns*

	#Si el directorio ya existe solo copiara el archivo en el.
	if test -d $path/$dir; then
		scp -rp dns:dns* $path/$dir

	#Si no existe lo creara y copiara el archivo.
	else

		mkdir $path/$dir
		scp -rp dns:dns* $path/$dir
	fi

	echo ""
	echo "[*] Backup del servidor dns realizado exitosamente."
	echo " >  Archivo copiado en $path/$dir/"
	echo ""

}

apacheBackup(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh apache2 bash -c "'
		#ifconfig | grep "inet" | head -n1 | tr -s '[:blank:]'
		rm -rf apache2*
		#Backup del servicio bind9
		(cd /etc/apache2/ && tar -cf /root/apache2.tar .) && (cd /var/www/ && tar -cf /root/www.tar .)
		cd /root/
		tar -czf apache2-$(date "+%d-%m-%Y_%H-%M").tar.gz apache2.tar www.tar
		rm -rf apache2.tar && rm -rf www.tar
	'"
	rm -rf $path/$dir/apache2*

	#Si el directorio ya existe solo copiara el archivo en el.
	if test -d $path/$dir; then
		scp -rp apache2:apache2* $path/$dir

	#Si no existe lo creara y copiara el archivo.
	else

		mkdir $path/$dir
		scp -rp apache2:apache2* $path/$dir
	fi

	echo ""
	echo "[*] Backup del servidor Web realizado exitosamente."
	echo " >  Archivo copiado en $path/$dir/"
	echo ""

}


#Se pasan argumentos como array y se almacenan en la variable hostnames
hostnames=("$@")
path=/home/BackUp
dir=$(date "+%d-%m-%Y")

# Si no se pasan argumentos.
if [ $# -eq 0 ]; then
	#withoutParameters
	mysqlBackup
	apacheBackup
	dnsBackup
else
#Si se pasan argumentos validos recorre la variable hostnames.
	for hostname in "${hostnames[@]}";
	do
		if [  "$hostname" == "mysql" ];then

			mysqlBackup

		elif [ "$hostname" == "dns"  ];then

			dnsBackup

		elif [ "$hostname" == "apache2"  ];then

			apacheBackup
		else

			let var=0
		fi
	done
fi

#Si se pasan argumentos que no estan contemplados llama al helpPanel
if [ "$var" == "0" ]; then

	helpPanel
fi
