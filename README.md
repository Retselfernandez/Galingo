# Galingo

![Estado: En Desarrollo](https://img.shields.io/badge/Estado-En%20Desarrollo-blue)
![Arquitectura: Microservicios](https://img.shields.io/badge/Arquitectura-Microservicios-orange)
![Stack: Python | Flutter | Docker](https://img.shields.io/badge/Stack-Python%20%7C%20Flutter%20%7C%20Docker-lightgrey)

**Galingo** es una plataforma integral y gamificada diseñada para la enseñanza y normalización del idioma gallego. A diferencia de las herramientas fragmentadas actuales, este proyecto unifica en una sola "súper app" el aprendizaje guiado, la repetición espaciada y la consulta gramatical profunda.

## Objetivo del Proyecto

El objetivo es proporcionar a los estudiantes una herramienta que no solo les permita memorizar vocabulario, sino estructurar oraciones y comprender la gramática de forma intuitiva, contando con "Gabi" (una gaviota interactiva) como mascota y guía visual del ecosistema.

La plataforma se divide en cuatro módulos principales:
1. **O Camiño:** Currículo lineal gamificado basado en la construcción de frases.
2. **A Forxa:** Motor de repetición espaciada para la asimilación de vocabulario complejo.
3. **O Laboratorio:** Herramientas integradas de consulta (conjugador de verbos y traductor).
4. **A Praza:** Entorno de inmersión con audio nativo.

## Arquitectura Técnica

El proyecto está diseñado bajo un enfoque escalable, utilizando:
* **Prototipado interactivo** y sistemas de diseño modulares gestionados en Figma.
* **Frontend híbrido** para un despliegue unificado en iOS y Android.
* **Backend asíncrono en Python**, apoyado por tareas en segundo plano (Celery/Redis) para el cálculo de curvas de olvido.
* **Infraestructura de microservicios** contenerizada, lista para ser orquestada y balanceada (Docker Swarm, Nginx) para garantizar alta disponibilidad en las consultas de diccionarios y lecciones.
