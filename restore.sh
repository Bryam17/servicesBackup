#!/bin/bash

helpPanel(){

	echo -e "\n\t\t\t------------------------------------------"
	echo -e "\t\t\t|Panel de ayuda de la herramienta restore|"
	echo -e "\t\t\t------------------------------------------\n"
	echo -e "\t[*] Funcionamiento de la herramienta: \n"
	echo -e "\t    [>] ./restore [backup_dir] [hostname]"
	echo -e "\t    [>] Ejemplo: ./restore.sh 15-10-22 mysql apache2 dns"
	echo -e "\t    [>] Se pueden proporcionar todos los parametros o algunos de ellos."
	echo -e "\t    [>] Si no se pasan parametros, se tomaran todos los parametros en cuenta.\n"
	echo -e "\t[*] Parametros validos: \n"
	echo -e "\t    [>] mysql"
	echo -e "\t    [>] apache2"
	echo -e "\t    [>] dns"
	echo -e "\t    [>] Nombre del directorio backup\n"
	cd /home/BackUp/
	echo -e "\t[*] Directorios de backups disponibles: \n\n\t    [>] $(ls | tr '\n' ' ')\n"
	echo -e "\t[*] Elaborado por:\n\n\t    [>] Bryam Vargas\n\t    [>] Roberto Berrios\n"
}

mysqlRestore(){

	scp $resPath/$backup/mysql* mysql:

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh mysql bash -c "'


		tar -xzf mysql* && rm -rf mysql*
		mysql -u root --password=12345 < backup.sql && rm -rf backup.sql

	'"
	if [ "$(echo $?)" == "0" ];then

		echo -e "\n[*] Restore del servidor de base de datos realizado exitosamente.\n"

	else

		exit 1;

	fi

}

dnsRestore(){

	scp $resPath/$backup/dns* dns:/etc/bind/

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh dns bash -c "'

		cd /etc/bind
		tar -xzf dns* && rm -rf dns*

	'"

	if [ "$(echo $?)" == "0" ];then

		echo -e "\n[*] Restore del servidor dns realizado exitosamente.\n"

	else

		exit 1;

	fi

}

apacheRestore(){

	scp $resPath/$backup/apache2* apache2:

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh apache2 bash -c "'

		tar -xzf apache2* && rm -rf apache2-*
		mv apache2.tar /etc/apache2/ && cd /etc/apache2 && tar -xf apache2.tar && rm -rf apache2.tar
		mv /root/www.tar /var/www/ && cd /var/www && tar -xf www.tar && rm -rf www.tar

	'"

	if [ "$(echo $?)" == "0" ];then

		echo -e "\n[*] Restore del servidor Web realizado exitosamente.\n"

	else

		exit 1;

	fi

}


#Primer argumento
backup=$1
#Se almacenan 3 argumentos en la variable hostnames.
hostnames=("$2" "$3" "$4")
#variable que contiene la ruta del directorio de backups.
resPath=/home/BackUp

#cambia al directorio de backups para posteriormente comprobar la existencia del primer argumento que se pasa.
cd /home/BackUp

# Si no se pasan argumentos llama al helpPanel.
if [ $# -eq 0 ];then

	echo -e "\n[*] Error: No se pasaron parametros."
	helpPanel

#si se pasan argumentos
else
	#evaluando si el primer argumento (directorio de backup) existe
	if [ -d "$backup" ];then

		#evaluando si no se pasan hostnames
		if [ -z $hostnames ];then

			#echo "Aqui se llevara a cabo el restore de todos los servidores"
			mysqlRestore
			dnsRestore
			apache2Restore

		#Si se pasan hostnames
		else
			#Si se pasan argumentos recorre cada elemento del array.
			for hostname in ${hostnames[@]};do

				if [  "$hostname" == "mysql" ];then

					mysqlRestore

				elif [ "$hostname" == "dns" ];then

					dnsRestore

				elif [ "$hostname" == "apache2" ];then

					apacheRestore

				#Si no se pasa como argumentos ninguna de las opciones anteriores
				else

					let var=1
					echo -e "\n[*] ERROR: El hostname $hostname no es valido."
				fi

			done

		fi

	#Si el directorio de backup no existe
	else

		echo -e "\n[*] ERROR: El directorio de backup $backup no existe."
		helpPanel

	fi

	#Si se pasan hostnames incorrectos se llama al helpPanel
	if [ "$var" == "1" ]; then

		helpPanel
	fi

fi


