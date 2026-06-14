using Microsoft.EntityFrameworkCore;
using ClinicaAPI.Models;

namespace ClinicaAPI.Data;

public class ClinicaDbContext : DbContext
{
    public ClinicaDbContext(DbContextOptions<ClinicaDbContext> options) : base(options) { }

    // Tablas principales
    public DbSet<Rol> Roles { get; set; }
    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Contacto> Contactos { get; set; }
    public DbSet<Empresa> Empresas { get; set; }
    public DbSet<TipoAsegurado> TiposAsegurado { get; set; }
    public DbSet<Especialidad> Especialidades { get; set; }
    public DbSet<Medico> Medicos { get; set; }
    public DbSet<Paciente> Pacientes { get; set; }
    public DbSet<EstadoCitaDb> EstadosCita { get; set; }
    public DbSet<Cita> Citas { get; set; }
    public DbSet<Medicamento> Medicamentos { get; set; }
    public DbSet<Receta> Recetas { get; set; }
    public DbSet<DetalleReceta> DetallesReceta { get; set; }
    public DbSet<Factura> Facturas { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Cita>()
            .HasOne(c => c.Paciente)
            .WithMany()
            .HasForeignKey(c => c.PacienteId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Cita>()
            .HasOne(c => c.MedicoNav)
            .WithMany()
            .HasForeignKey(c => c.MedicoId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Paciente>()
            .HasOne(p => p.Usuario)
            .WithOne()
            .HasForeignKey<Paciente>(p => p.IdUsuario);

        modelBuilder.Entity<Medico>()
            .HasOne(m => m.Usuario)
            .WithOne()
            .HasForeignKey<Medico>(m => m.IdUsuario);
    }
}
