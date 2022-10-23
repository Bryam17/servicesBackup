#!/bin/bash

helpPanel(){

	echo -e "\n\t\t\t-----------------------------------------"
	echo -e "\t\t\t|Panel de ayuda de la herramienta backup|"
	echo -e "\t\t\t-----------------------------------------\n"
	echo -e "\t[*] Funcionamiento de la herramienta: \n"
	echo -e "\t    [>] ./backup.sh [hostname]"
	echo -e "\t    [>] Ejemplo: ./backup.sh mysql apache2 dns"
	echo -e "\t    [>] Se pueden proporcionar todos los parametros (3) o algunos de ellos."
	echo -e "\t    [>] Si no se pasan parametros, se tomaran todos los parametros en cuenta.\n"
	echo -e "\t[*] Parametros validos: \n"
	echo -e "\t    [>] mysql"
	echo -e "\t    [>] apache2"
	echo -e "\t    [>] dns\n"
	echo -e "\t[*] Elabordado por:\n\n\t    [>] Bryam Vargas\n\t    [>] Roberto Berrios\n"

}

mysqlBackup(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh mysql bash -c "'

		rm -rf mysql*
		#Backup de todas las bases de datos
		mysqldump -u root --password=123 --all-databases > backup.sql
		tar -czf mysql-$(date "+%d-%m-%Y_%H-%M").tar.gz backup.sql

	'"

	#Si el comando anterior devuelve un codigo de estado igual a cero es que se ejecuto correctamente
	if [ "$(echo $?)" == "0" ];then

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

		ssh mysql bash -c "'

		rm -rf mysql*

		'"

		echo -e "\n[*] Backup del servidor de base de datos realizado exitosamente."
		echo -e " >  Archivo copiado en $path/$dir/\n"

	#Si el codigo de estado es diferente de cero hubo un error
	else

		echo -e "\n[*] ERROR\n"
		exit 1;

	fi

}

dnsBackup(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh dns bash -c "'

		rm -rf dns*

		#Backup del servicio bind9
		cd /etc/bind/ && tar -czf /root/dns-$(date "+%d-%m-%Y_%H-%M").tar.gz . 
	'"

	#Si el comando anterior devuelve un codigo de estado igual a cero es que se ejecuto correctamente
	if [ "$(echo $?)" == "0" ];then

		rm -rf $path/$dir/dns*

		#Si el directorio ya existe solo copiara el archivo en el.
		if test -d $path/$dir; then

			scp -rp dns:dns* $path/$dir

		#Si no existe lo creara y copiara el archivo.
		else

			mkdir $path/$dir
			scp -rp dns:dns* $path/$dir
		fi

		ssh dns bash -c "'

		rm -rf dns*

		'"

		echo -e "\n[*] Backup del servidor dns realizado exitosamente."
		echo -e " >  Archivo copiado en $path/$dir/\n"

	#Si el codigo de estado es diferente de cero hubo error 
	else

		echo -e "\n[*] ERROR\n"
		exit 1;

	fi

}

apacheBackup(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh apache2 bash -c "'

		rm -rf apache2*

		#Backup del servicio bind9
		(cd /etc/apache2/ && tar -cf /root/apache2.tar .) && (cd /var/www/ && tar -cf /root/www.tar .)
		cd /root/
		tar -czf apache2-$(date "+%d-%m-%Y_%H-%M").tar.gz apache2.tar www.tar
		rm -rf apache2.tar && rm -rf www.tar
	'"

	#Si el comando anterior devuelve un codigo de estado igual a cero es que se ejecuto correctamente
	if [ "$(echo $?)" == "0" ];then

		rm -rf $path/$dir/apache2*

		#Si el directorio ya existe solo copiara el archivo en el.
		if test -d $path/$dir; then
			scp -rp apache2:apache2* $path/$dir

		#Si no existe lo creara y copiara el archivo.
		else

			mkdir $path/$dir
			scp -rp apache2:apache2* $path/$dir
		fi

		ssh apache2 bash -c "'

			rm -rf /root/apache2*

		'"

		echo -e "\n[*] Backup del servidor Web realizado exitosamente."
		echo -e " >  Archivo copiado en $path/$dir/\n"

	#Si el codigo de estado es diferente de cero hubo error
	else

		echo -e "\n[*] ERROR\n"
		exit 1;

	fi

}

#Se pasan argumentos como array y se almacenan en la variable hostnames
hostnames=("$@")
path=/home/BackUp
dir=$(date "+%d-%m-%Y")

# Si no se pasan argumentos.
if [ $# -eq 0 ]; then

	mysqlBackup
	apacheBackup
	dnsBackup
else
#Si se pasan argumentos validos recorre la variable hostnames.
	for hostname in "${hostnames[@]}";
	do
		if [  "$hostname" == "mysql" ];then

			mysqlBackup
			#let mysql=1

		elif [ "$hostname" == "dns"  ];then

			dnsBackup
			#let dns=1

		elif [ "$hostname" == "apache2"  ];then

			apacheBackup
			#let apache2=1
		else

			name=$hostname
			let var=0
		fi
	done
fi

#Si se pasan argumentos incorrectos llama al helpPanel
if [ "$var" == "0" ]; then

	echo -e "\n[>] El servidor $name es invalido."
	helpPanel
fi
