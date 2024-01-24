// UDP server that use non-blocking sockets
#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>
#include "conio.h"
#include <string>

#pragma comment (lib, "Ws2_32.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")

#define SERVER_PORT 21000	// Port number of server that will be used for communication with clients
#define SERVER_PORT1 21001
#define BUFFER_SIZE 512		// Size of buffer that will be used for sending and receiving messages to clients
#define MAX_STANJE 100000
#define MAX_RACUNA 5
#define MAX_SUMA 50000

struct Racun{
	int stanje = 0;
};

struct Transakcija {
	short brojRacuna;
	char tip[50];
	short suma;
};

int main()
{
	// Server address
	Racun racuni[MAX_RACUNA];
	for (int i = 0;i < MAX_RACUNA;i++) {
		racuni[i].stanje = 0;
	}
	sockaddr_in serverAddress;
	sockaddr_in serverAddress1;

	// Buffer we will use to send and receive clients' messages
	char dataBuffer[BUFFER_SIZE];


	// WSADATA data structure that is to receive details of the Windows Sockets implementation
	WSADATA wsaData;

	// Initialize windows sockets library for this process
	if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0)
	{
		printf("WSAStartup failed with error: %d\n", WSAGetLastError());
		return 1;
	}

	// Initialize serverAddress structure used by bind function
	memset((char*)&serverAddress, 0, sizeof(serverAddress));
	serverAddress.sin_family = AF_INET; 			// set server address protocol family
	serverAddress.sin_addr.s_addr = INADDR_ANY;		// use all available addresses of server
	serverAddress.sin_port = htons(SERVER_PORT);

	memset((char*)&serverAddress1, 0, sizeof(serverAddress1));
	serverAddress1.sin_family = AF_INET; 			// set server address protocol family
	serverAddress1.sin_addr.s_addr = INADDR_ANY;		// use all available addresses of server
	serverAddress1.sin_port = htons(SERVER_PORT1);

	// Create a socket
	SOCKET serverSocket = socket(AF_INET,      // IPv4 address famly
		SOCK_DGRAM,   // datagram socket
		IPPROTO_UDP); // UDP

	SOCKET serverSocket1 = socket(AF_INET,      // IPv4 address famly
		SOCK_DGRAM,   // datagram socket
		IPPROTO_UDP); // UDP

	// Check if socket creation succeeded
	if (serverSocket == INVALID_SOCKET)
	{
		printf("Creating socket failed with error: %d\n", WSAGetLastError());
		WSACleanup();
		return 1;
	}

	if (serverSocket1 == INVALID_SOCKET)
	{
		printf("Creating socket failed with error: %d\n", WSAGetLastError());
		WSACleanup();
		return 1;
	}

	// Bind server address structure (type, port number and local address) to socket
	int iResult = bind(serverSocket, (SOCKADDR*)&serverAddress, sizeof(serverAddress));
	iResult = bind(serverSocket1, (SOCKADDR*)&serverAddress1, sizeof(serverAddress1));

	// Check if socket is succesfully binded to server datas
	if (iResult == SOCKET_ERROR)
	{
		printf("Socket bind failed with error: %d\n", WSAGetLastError());
		closesocket(serverSocket);
		closesocket(serverSocket1);
		WSACleanup();
		return 1;
	}

	printf("Simple UDP server started and waiting client messages.\n");

	// Declare and initialize client address that will be set from recvfrom
	sockaddr_in clientAddress;
	memset(&clientAddress, 0, sizeof(clientAddress));

	memset(dataBuffer, 0, BUFFER_SIZE);

	int sockAddrLen = sizeof(clientAddress);

	//set serverSocket in nonblocking mode 
	unsigned long  mode = 1;
	iResult = ioctlsocket(serverSocket, FIONBIO, &mode);
	iResult = ioctlsocket(serverSocket1, FIONBIO, &mode);
	if (iResult != 0)
		printf("ioctlsocket failed with error.");

	int NOATTEMPTS = 30; 

	// Main server loop
	while (true)
	{
		int i;

		printf("\nUDP server waiting for new messages\n");

		for (i = 0; i < NOATTEMPTS; i++)
		{
			printf("Attempt #%d\n", i + 1);

			iResult = recvfrom(serverSocket, dataBuffer, BUFFER_SIZE, 0, (SOCKADDR*)&clientAddress, &sockAddrLen);

			if (iResult != SOCKET_ERROR)
			{
				// Set end of string
				//dataBuffer[iResult] = '\0';
				char ipAddress[16];
				strcpy_s(ipAddress, sizeof(ipAddress), inet_ntoa(clientAddress.sin_addr));
				unsigned short clientPort = ntohs(clientAddress.sin_port);
				printf("Client (ip: %s, port: %d) sent: %s.\n", ipAddress, SERVER_PORT, dataBuffer);
			}

			iResult = recvfrom(serverSocket1, dataBuffer, BUFFER_SIZE, 0, (SOCKADDR*)&clientAddress, &sockAddrLen);

			if (iResult != SOCKET_ERROR)
			{
				char ipAddress[16];
				strcpy_s(ipAddress, sizeof(ipAddress), inet_ntoa(clientAddress.sin_addr));
				unsigned short clientPort = ntohs(clientAddress.sin_port);
				printf("Client (ip: %s, port: %d) sent: %s.\n", ipAddress, SERVER_PORT1, dataBuffer);
			}

			int x = MAX_RACUNA;
			int y = MAX_STANJE;

			if (strcmp(dataBuffer, "Prijava") == 0) {

				char dataBuffer1[BUFFER_SIZE];
				sprintf_s(dataBuffer1, "Prijava uspesna! Na serveru postoji %d racuna. Limit svakog je %d", MAX_RACUNA, MAX_STANJE);

				if (SERVER_PORT1)
					iResult = sendto(serverSocket1, dataBuffer1, BUFFER_SIZE, 0, (SOCKADDR*)&clientAddress, sizeof(clientAddress));
				else if (SERVER_PORT)
					iResult = sendto(serverSocket, dataBuffer1, BUFFER_SIZE, 0, (SOCKADDR*)&clientAddress, sizeof(clientAddress));
			}

			else
			{
				if (WSAGetLastError() == WSAEWOULDBLOCK)
				{
					Sleep(1000);
				}

				else
				{
					printf("recvfrom failed with error: %d\n", WSAGetLastError());
					iResult = closesocket(serverSocket);
					iResult = closesocket(serverSocket1);
					WSACleanup();
					return 1;
				}
			}

			Transakcija* tr;
			char dataBuffer2[BUFFER_SIZE];

			if (SERVER_PORT){
				iResult = recvfrom(serverSocket, dataBuffer2, BUFFER_SIZE, 0, (SOCKADDR*)&clientAddress, &sockAddrLen);
			}
		 if (SERVER_PORT1) {
				iResult = recvfrom(serverSocket1, dataBuffer2, BUFFER_SIZE, 0, (SOCKADDR*)&clientAddress, &sockAddrLen);
			}

			if (iResult > 0)
			{
				dataBuffer2[iResult] = '\0';
				printf("Message received from client (%d):\n", i + 1);

				tr = (Transakcija*)dataBuffer2;

				printf("Broj racuna: %d  \n", ntohs(tr->brojRacuna));

				printf("Tip: %c  \n", tr->tip);

				printf("Suma: %d \n", ntohs(tr->suma));

			}

		}
		if (i == NOATTEMPTS)
		{
			break;
		}
	}

	iResult = closesocket(serverSocket);
	iResult = closesocket(serverSocket1);
	if (iResult == SOCKET_ERROR)
	{
		printf("closesocket failed with error: %ld\n", WSAGetLastError());
		WSACleanup();
		return 1;
	}

	printf("Server successfully shut down.\n");

	WSACleanup();
	return 0;
}
