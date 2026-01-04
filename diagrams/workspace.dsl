workspace "SOK.NET" "System Organizacji Kolędy" {

    !identifiers hierarchical

    model {
        staff = person "Personel" {
            description "Osoba korzystająca z systemu."
            tags "Personel"
        }

        submitter = person "Parafianin" {
            description "Anonimowy użytkownik przeglądający dane swojego zgłoszenia i termin wizyty."
            tags "Parafianin"
        }
        
        system = softwareSystem "SOK" {
            description "System Organizacji Kolędy."
            tags "System SOK"

            webapp = container "Aplikacja internetowa" {
                description "Dostarcza widoki oraz funkcje zarządzania kolędą."
                technology "ASP.NET Core MVC"
                tags "Aplikacja internetowa"

                group "Serwis administracyjny" {
                    controller = component "Kontroler MVC" {
                        description "Obsługuje żądania HTTPS i zwraca widoki Razor."
                        technology "ASP.NET Core"
                        tags "Kontroler MVC"
                    }
                    authorization = component "Autoryzacja" {
                        description "Zapewnia mechanizmy autoryzacji i uwierzytelniania użytkowników."
                        technology "ASP.NET Core Identity"
                        tags "Autoryzacja"
                    }
                }
                group "Serwis publiczny" {
                    publiccontroller = component "Kontroler publiczny" {
                        description "Obsługuje żądania HTTPS i zwraca widoki Razor."
                        technology "ASP.NET Core"
                        tags "Kontroler publiczny"
                    }
                }

                service = component "Usługa" {
                    description "Zawiera logikę biznesową aplikacji."
                    technology "C#"
                    tags "Usługa"
                }
                repository = component "Repozytorium" {
                    description "Zawiera logikę dostępu do danych."
                    technology "Entity Framework Core"
                    tags "Repozytorium"
                }
                pdfmaker = component "Generator PDF" {
                    description "Generuje dokumenty PDF."
                    technology "QuestPDF"
                    tags "Generator PDF"
                }

                controller -> service "Korzysta z"
                controller -> authorization "Uwierzytelnia użytkowników za pomocą"
                publiccontroller -> service "Korzysta z"
                service -> repository "Korzysta z"
                service -> pdfmaker "Korzysta z"
            }
            apiapp = container "Aplikacja API" {
                description "Dostarcza funkcje zarządzania kolędą z użyciem JSON/HTTPS."
                technology "ASP.NET Core"
                tags "Aplikacja API"

                controller = component "Kontroler API" {
                    description "Obsługuje żądanie HTTPS i zwraca dane w formacie JSON."
                    technology "ASP.NET Core"
                    tags "Kontroler API"
                }
                authorization = component "Autoryzacja" {
                    description "Zapewnia mechanizmy autoryzacji i uwierzytelniania użytkowników."
                    technology "ASP.NET Core Identity"
                    tags "Autoryzacja"
                }
                service = component "Usługa" {
                    description "Zawiera logikę biznesową aplikacji."
                    technology "C#"
                    tags "Usługa"
                }
                repository = component "Repozytorium" {
                    description "Zawiera logikę dostępu do danych."
                    technology "Entity Framework Core"
                    tags "Repozytorium"
                }
                pdfmaker = component "Generator PDF" {
                    description "Generuje dokumenty PDF."
                    technology "QuestPDF"
                    tags "Generator PDF"
                }

                controller -> service "Korzysta z"
                controller -> authorization "Uwierzytelnia użytkowników za pomocą"
                service -> repository "Korzysta z"
                service -> pdfmaker "Korzysta z"
            }

            group "Usługi publiczne" {
                publicview = container "Widok publiczny" {
                    description "Umożliwia parafianom wysyłanie formularzy oraz przeglądanie informacji o swoich zgłoszeniach."
                    technology "HTML"
                    tags "Widok publiczny"
                }
            }

            view = container "Widok" {
                description "Umożliwia przemieszczanie się po serwisie oraz wykonywanie operacji za pomocą przesyłanych formularzy oraz aplikacji Vue.js."
                technology "HTML & Vue.js"
                tags "Widok"
            }

            db = container "Baza danych" {
                tags "Database"
                description "Przechowuje wszystkie dane aplikacji."
                technology "Microsoft SQL Server"
            }
        }

        email = softwareSystem "Serwer pocztowy" {
            description "Zewnętrzny serwer pocztowy konkretnej parafii."
            tags "Serwer pocztowy"
        }

        staff -> system.webapp.controller "Odwiedza aplikację internetową za pomocą" "HTTPS"
        staff -> system.view "Zarządza kolędą w granicach swojej roli za pomocą"
        
        submitter -> system.webapp.publiccontroller "Odwiedza aplikację internetową za pomocą" "HTTPS"
        submitter -> system.publicview "Wysyła formularze i przegląda swoje informacje za pomocą"

        system.webapp.controller -> system.view "Dostarcza" "Razor"
        system.webapp.publiccontroller -> system.publicview "Dostarcza" "Razor"
        system.view -> system.apiapp.controller "Korzysta z API" "JSON/HTTPS"
        
        system.webapp.repository -> system.db "Odczytuje i zapisuje dane" "Entity Framework Core"
        system.webapp.authorization -> system.db "Odczytuje i zapisuje dane" "Entity Framework Core"
        system.apiapp.repository -> system.db "Odczytuje i zapisuje dane" "Entity Framework Core"
        system.apiapp.authorization -> system.db "Odczytuje i zapisuje dane" "Entity Framework Core"

        system.webapp.service -> email "Wysyła powiadomienia mailowe za pomocą" "SMTP"
        system.apiapp.service -> email "Wysyła powiadomienia mailowe za pomocą" "SMTP"
        email -> submitter "Wysyła powiadomienia mailowe do"
        
        // Deployment
        production = deploymentEnvironment "Produkcja" {
            vps = deploymentNode "VPS" {
                tags "VPS Server"
                description "Serwer wirtualny (np. OVHCloud)"
                
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    
                    traefik = deploymentNode "Traefik" {
                        tags "Traefik Container"
                        description "Reverse proxy i load balancer"
                        technology "Traefik 3.6.2"
                        
                        reverseProxy = infrastructureNode "Reverse Proxy" {
                            tags "Infrastructure"
                            description "Obsługuje routing HTTPS i certyfikaty SSL"
                        }
                        
                        letsEncrypt = infrastructureNode "Let's Encrypt" {
                            tags "Infrastructure"
                            description "Automatyczne zarządzanie certyfikatami SSL/TLS"
                        }
                    }
                    
                    sokWebContainer = deploymentNode "SOK Web Container" {
                        tags "Docker Container"
                        description "Kontener aplikacji ASP.NET Core"
                        technology "Docker"
                        instances "1"
                        
                        webAppInstance = containerInstance system.webapp
                        apiAppInstance = containerInstance system.apiapp
                        viewInstance = containerInstance system.view
                        publicViewInstance = containerInstance system.publicview
                    }
                    
                    sqlServerContainer = deploymentNode "SQL Server Container" {
                        tags "Docker Container Database"
                        description "Kontener bazy danych"
                        technology "SQL Server 2022"
                        instances "1"
                        
                        databaseInstance = containerInstance system.db
                    }
                }
                
                volumes = infrastructureNode "Docker Volumes" {
                    tags "Infrastructure Storage"
                    description "Persystentne przechowywanie danych (mssql_data, letsencrypt)"
                }
            }
            
            internet = deploymentNode "Internet" {
                tags "External"
                
                users = infrastructureNode "Użytkownicy" {
                    tags "External Users"
                    description "Personel i parafianie"
                }
            }
            
            externalEmail = deploymentNode "Serwer pocztowy parafii" {
                tags "External Email"
                description "Zewnętrzny serwer SMTP"
                
                emailInstance = softwareSystemInstance email
            }
            
            // Relacje deployment
            internet.users -> production.vps.docker.traefik.reverseProxy "Żądania HTTPS" "HTTPS:443"
            production.vps.docker.traefik.reverseProxy -> production.vps.docker.sokWebContainer.webAppInstance "Przekazuje żądania" "HTTP:8080"
            production.vps.docker.traefik.reverseProxy -> production.vps.docker.traefik.letsEncrypt "Pobiera certyfikaty"
            // production.vps.docker.sokWebContainer.webAppInstance -> production.vps.docker.sqlServerContainer.databaseInstance "Odczytuje/zapisuje dane" "SQL Server:1433"
            // production.vps.docker.sokWebContainer.apiAppInstance -> production.vps.docker.sqlServerContainer.databaseInstance "Odczytuje/zapisuje dane" "SQL Server:1433"
            // production.vps.docker.sokWebContainer.webAppInstance -> externalEmail.emailInstance "Wysyła emaile" "SMTP"
            // production.vps.docker.sokWebContainer.apiAppInstance -> externalEmail.emailInstance "Wysyła emaile" "SMTP"
            production.vps.docker.sqlServerContainer.databaseInstance -> production.vps.volumes "Zapisuje dane"
            production.vps.docker.traefik.letsEncrypt -> production.vps.volumes "Zapisuje certyfikaty"
        }
    }

    views {
        systemContext system "Diagram1" {
            include *
            autolayout lr
        }

        container system "Diagram2" {
            include *
        }

        component system.webapp "Diagram3" {
            include *
        }

        component system.apiapp "Diagram4" {
            include *
            include staff
        }
        
        deployment system production "Diagram5" {
            include *
        }

        styles {
            element "Element" {
                strokeWidth 4
                shape roundedbox
                fontSize 24
                color #ffffff
            }
            
            element "Person" {
                shape person
                background #08427b
                color #ffffff
                fontSize 28
            }
            
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            
            element "Container" {
                background #438dd5
                color #ffffff
            }
            
            element "Component" {
                background #85bbf0
                color #000000
            }
            
            element "Database" {
                shape cylinder
                background #438dd5
                color #ffffff
            }
            
            // Specjalne style dla grup logicznych
            element "Personel" {
            }
            element "Parafianin" {
                background #2a9d8f
            }

            element "System SOK" {
                background #605dff
            }
            
            element "Serwis administracyjny" {
                background #d95d39
                color #ffffff
            }
            
            element "Serwis publiczny" {
                background #52b788
                color #ffffff
            }
            
            element "Usługi publiczne" {
                background #52b788
                color #ffffff
            }
            
            // Komponenty według typu - ŚCIEŻKA PERSONELU (czerwono-pomarańczowa)
            element "Kontroler MVC" {
                background #d95d39
                color #ffffff
                shape hexagon
            }
            
            element "Kontroler API" {
                background #d95d39
                color #ffffff
                shape hexagon
            }
            
            // Komponenty według typu - ŚCIEŻKA PARAFIANINA (zielona)
            element "Kontroler publiczny" {
                background #52b788
                color #ffffff
                shape hexagon
            }
            
            // Komponenty współdzielone - backend
            element "Autoryzacja" {
                background #FD5E5E
                color #ffffff
                shape component
            }
            
            element "Usługa" {
                background #457b9d
                color #ffffff
            }
            
            element "Repozytorium" {
                background #6c757d
                color #ffffff
            }
            
            element "Generator PDF" {
                background #f77f00
                color #ffffff
                shape component
            }
            
            // Widoki - ŚCIEŻKA PERSONELU (jasnoniebieski)
            element "Widok" {
                background #b8d4f1
                color #000000
                shape webBrowser
            }
            
            // Widoki - ŚCIEŻKA PARAFIANINA (jasnozielony)
            element "Widok publiczny" {
                background #a7e1c4
                color #000000
                shape webBrowser
            }
            
            element "Aplikacja internetowa" {
                background #7775FC
                color #ffffff
            }
            
            element "Aplikacja API" {
                background #9C9AFF
                color #ffffff
            }
            
            // System zewnętrzny
            element "Serwer pocztowy" {
                background #999999
                color #ffffff
                stroke #7F7F7F
                strokeWidth 5
            }
            
            // Deployment - Infrastructure
            element "Deployment Node" {
                background #ffffff
                color #000000
                stroke #999999
                strokeWidth 2
            }
            
            element "VPS Server" {
                background #e8f4f8
                color #000000
                shape box
                stroke #3498db
                strokeWidth 4
            }
            
            element "Docker" {
                background #d6eaf8
                color #000000
                shape roundedBox
                stroke #2874a6
                strokeWidth 3
            }
            
            element "Docker Container" {
                background #aed6f1
                color #000000
                shape roundedBox
                stroke #1f618d
                strokeWidth 2
            }
            
            element "Docker Container Database" {
                background #85c1e9
                color #000000
                shape cylinder
                stroke #1f618d
                strokeWidth 2
            }
            
            element "Traefik Container" {
                background #ffeaa7
                color #000000
                shape hexagon
                stroke #fdcb6e
                strokeWidth 3
            }
            
            element "Infrastructure" {
                background #dfe6e9
                color #000000
                shape ellipse
                stroke #636e72
                strokeWidth 2
            }
            
            element "Infrastructure Storage" {
                background #b2bec3
                color #000000
                shape folder
                stroke #636e72
                strokeWidth 2
            }
            
            element "External" {
                background #fff5e1
                color #000000
                shape roundedBox
                stroke #ffa500
                strokeWidth 3
            }
            
            element "External Users" {
                background #fdcb6e
                color #000000
                shape person
                stroke #e17055
                strokeWidth 2
            }
            
            element "External Email" {
                background #dfe6e9
                color #000000
                shape roundedBox
                stroke #636e72
                strokeWidth 2
            }
            
            element "Boundary" {
                strokeWidth 3
            }
            
            relationship "Relationship" {
                thickness 5
                fontSize 24
                color #404040
            }
        }
    }

    configuration {
        scope softwaresystem
    }

}