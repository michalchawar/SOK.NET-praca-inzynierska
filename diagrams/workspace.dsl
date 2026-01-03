workspace "SOK.NET" "System Organizacji Kolędy" {

    !identifiers hierarchical

    model {
        staff = person "Personel" {
            description "Osoba korzystająca z systemu."
        }

        submitter = person "Parafianin" {
            description "Anonimowy użytkownik przeglądający dane swojego zgłoszenia i termin wizyty."
        }
        
        system = softwareSystem "SOK" {
            description "System Organizacji Kolędy"

            webapp = container "Aplikacja internetowa" {
                description "Dostarcza widoki oraz funkcje zarządzania kolędą."
                technology "ASP.NET Core MVC"

                group "Serwis administracyjny" {
                    controller = component "Kontroler MVC" {
                        description "Obsługuje żądania HTTPS i zwraca widoki Razor."
                        technology "ASP.NET Core"
                    }
                    authorization = component "Autoryzacja" {
                        description "Zapewnia mechanizmy autoryzacji i uwierzytelniania użytkowników."
                        technology "ASP.NET Core Identity"
                    }
                }
                group "Serwis publiczny" {
                    publiccontroller = component "Kontroler publiczny" {
                        description "Obsługuje żądania HTTPS i zwraca widoki Razor."
                        technology "ASP.NET Core"
                    }
                }

                service = component "Usługa" {
                    description "Zawiera logikę biznesową aplikacji."
                    technology "C#"
                }
                repository = component "Repozytorium" {
                    description "Zawiera logikę dostępu do danych."
                    technology "Entity Framework Core"
                }
                pdfmaker = component "Generator PDF" {
                    description "Generuje dokumenty PDF."
                    technology "QuestPDF"
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

                controller = component "Kontroler API" {
                    description "Obsługuje żądanie HTTPS i zwraca dane w formacie JSON."
                    technology "ASP.NET Core"
                }
                authorization = component "Autoryzacja" {
                    description "Zapewnia mechanizmy autoryzacji i uwierzytelniania użytkowników."
                    technology "ASP.NET Core Identity"
                }
                service = component "Usługa" {
                    description "Zawiera logikę biznesową aplikacji."
                    technology "C#"
                }
                repository = component "Repozytorium" {
                    description "Zawiera logikę dostępu do danych."
                    technology "Entity Framework Core"
                }
                pdfmaker = component "Generator PDF" {
                    description "Generuje dokumenty PDF."
                    technology "QuestPDF"
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
                }
            }

            view = container "Widok" {
                description "Umożliwia przemieszczanie się po serwisie oraz wykonywanie operacji za pomocą przesyłanych formularzy oraz aplikacji Vue.js."
                technology "HTML & Vue.js"
            }

            db = container "Baza danych" {
                tags "Database"
                description "Przechowuje wszystkie dane aplikacji."
                technology "Microsoft SQL Server"
            }
        }

        email = softwareSystem "System pocztowy" {
            description "Zewnętrzne serwery pocztowe indywidualnych parafii."
        }

        staff -> system.webapp.controller "Odwiedza aplikację internetową za pomocą" "HTTPS"
        staff -> system.view "Zarządza kolędą w granicach swojej roli za pomocą"
        
        submitter -> system.webapp.publiccontroller "Odwiedza aplikację internetową za pomocą" "HTTPS"
        submitter -> system.publicview "Wysyła formularze i przegląda swoje informacje za pomocą" "HTTPS"

        system.webapp.controller -> system.view "Dostarcza" "Razor"
        system.webapp.publiccontroller -> system.publicview "Dostarcza" "Razor"
        system.view -> system.apiapp.controller "Korzysta z API" "JSON/HTTPS"
        
        system.webapp.repository -> system.db "Odczytuje i zapisuje dane" "Entity Framework Core"
        system.apiapp.repository -> system.db "Odczytuje i zapisuje dane" "Entity Framework Core"

        system.webapp.service -> email "Wysyła powiadomienia mailowe za pomocą" "SMTP"
        system.apiapp.service -> email "Wysyła powiadomienia mailowe za pomocą" "SMTP"
        email -> submitter "Wysyła powiadomienia mailowe do"
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
            autolayout lr
        }

        styles {
            element "Element" {
                strokeWidth 7
                shape roundedbox
            }
            element "Person" {
                shape person
            }
            element "Database" {
                shape cylinder
            }
            element "Boundary" {
                strokeWidth 5
            }
            relationship "Relationship" {
                thickness 4
            }
        }
    }

    configuration {
        scope none
    }

}