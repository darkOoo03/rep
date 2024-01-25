// UDP client that uses non-blocking sockets
#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define WIN32_LEAN_AND_MEAN
https://pastebin.com/u/ranandrej
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>
#include "conio.h"
#include <iostream>

#pragma comment (lib, "Ws2_32.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")

#define SERVER_IP_ADDRESS "192.168.56.1"		// IPv4 address of server
#define SERVER_PORT 21000
#define SERVER_PORT1 21001  					// Port number of server that will be used for communication with clients
#define BUFFER_SIZE 2048						// Size of buffer that will be used for sending and receiving messages to client

#define MAX_RACUNA 5
#define MAX_SUMA 50000

using namespace std;

struct Transakcija {
    short brojRacuna;
    char tip[50];
    short suma;
};

int main()
{
    sockaddr_in serverAddress;

    int sockAddrLen = sizeof(serverAddress);

    char dataBuffer[BUFFER_SIZE];
    char dataBuffer1[BUFFER_SIZE];

    WSADATA wsaData;

    int iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);

    if (iResult != 0)
    {
        printf("WSAStartup failed with error: %d\n", iResult);
        return 1;
    }

    memset((char*)&serverAddress, 0, sizeof(serverAddress));

    int opcija;
    printf("Unesi opciju 1 za port21000 ili 2 za port21001: ");
    scanf_s("%d",&opcija);
    switch (opcija) {
        case 1: 
            serverAddress.sin_family = AF_INET;
            serverAddress.sin_addr.s_addr = inet_addr(SERVER_IP_ADDRESS);
            serverAddress.sin_port = htons(SERVER_PORT);
            break;
        case 2:
            serverAddress.sin_family = AF_INET;								
            serverAddress.sin_addr.s_addr = inet_addr(SERVER_IP_ADDRESS);
            serverAddress.sin_port = htons(SERVER_PORT1);
            break;
    }
   					
    SOCKET clientSocket = socket(AF_INET,      
        SOCK_DGRAM,                            
        IPPROTO_UDP);                          

    if (clientSocket == INVALID_SOCKET)
    {
        printf("Creating socket failed with error: %d\n", WSAGetLastError());
        WSACleanup();
        return 1;
    }

    printf("Enter message to send: ");
    cin.ignore();
    
    gets_s(dataBuffer, BUFFER_SIZE);

    iResult = sendto(clientSocket, dataBuffer, strlen(dataBuffer), 0, (SOCKADDR*)&serverAddress, sizeof(serverAddress));			

    iResult = recvfrom(clientSocket, dataBuffer1, BUFFER_SIZE, 0,(SOCKADDR*)&serverAddress, &sockAddrLen);

    if (iResult != SOCKET_ERROR)
    {
        printf("Server sent: %s.\n", dataBuffer1);
    }

    if (iResult == SOCKET_ERROR)
    {
        printf("sendto failed with error: %d\n", WSAGetLastError());
        closesocket(clientSocket);
        WSACleanup();
        return 1;
        
    }
     
    Transakcija tr;
    short suma;
    short brojRacuna;
    char dataBuffer2[BUFFER_SIZE];

        printf("Unesi broj racuna: ");
        scanf_s("%d", &brojRacuna);
        getchar();
        tr.suma = htons(brojRacuna);

        printf("Unesi tip: ");
        gets_s(tr.tip, 50);

        printf("Unesi sumu: ");
        scanf_s("%d",&suma);
        getchar();
        tr.suma = htons(suma);


        iResult = sendto(clientSocket, (char*)&tr, strlen(dataBuffer), 0, (SOCKADDR*)&serverAddress, sizeof(serverAddress));

        if (iResult == SOCKET_ERROR)
        {
            printf("send failed with error: %d\n", WSAGetLastError());
            closesocket(clientSocket);
            WSACleanup();
            return 1;
        }

        printf("Message successfully sent. Total bytes: %ld\n", iResult);
    
    printf("Press any key to exit: ");
    _getch();

    iResult = closesocket(clientSocket);
    if (iResult == SOCKET_ERROR)
    {
        printf("closesocket failed with error: %d\n", WSAGetLastError());
        WSACleanup();
        return 1;
    }

    WSACleanup();

    return 0;
}
