db.createUser(
    {
        user: "geos",
        pwd: "geos_local_password_here",
        roles: [
            {
                role: "readWrite",
                db: "guia_edutec"
            }
        ]
    }
);
