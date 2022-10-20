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
}

mysqlRestore(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh mysql bash -c "'

		#ifconfig | grep "inet" | head -n1 | tr -s '[:blank:]'
		#echo ""
		

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
	echo "[*] Restore del servidor de base de datos realizado exitosamente."
	echo ""

}

dnsRestore(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh dns bash -c "'
		 
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
	echo "[*] Restore del servidor dns realizado exitosamente."
	echo ""

}

apacheRestore(){

	#Establece una conexion ssh hacia el hostname indicado y ejecuta los siguientes comandos a nivel de sistema
	ssh apache2 bash -c "'
		
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
	echo "[*] Restore del servidor Web realizado exitosamente."
	echo ""

}


#Primer argumento
backup=$1
#Se almacenan 3 argumentos en la variable hostnames.
hostnames=("$2" "$3" "$4")
#variables que contiene la ruta del directorio de backups.
path=/home/BackUp
dir=$(date "+%d-%m-%Y")

#cambia al directorio de backups para posteriormente comprobar la existencia del primer argumento que se pasa.
cd /home/BackUp

# Si no se pasan argumentos llama al helpPanel.
if [ $# -eq 0 ];then

	echo -e "\n[*] Error: No se pasaron parametros."
	helpPanel

#si se pasan argumentos
else
	#evaluando si el primer argumento(directorio de backup) existe
	if [ -d "$backup" ];then

		#evaluando si no se pasan hostnames
		if [ -z $hostnames ];then

			echo "Aqui se llevara a cabo el restore de todos los servidores"

		#Si se pasan hostnames
		else
			#Si se pasan argumentos(hostnames) validos los recorre.
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
					host=$hostname
					echo -e "\n[*] ERROR: El hostname $host no es valido."
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


