using Microsoft.EntityFrameworkCore;
using ClinicaAPI.Models;

namespace ClinicaAPI.Data;

public class ClinicaDbContext : DbContext
{
    public ClinicaDbContext(DbContextOptions<ClinicaDbContext> options) : base(options) { }

    // Catálogos
    public DbSet<Rol> Roles { get; set; }
    public DbSet<Especialidad> Especialidades { get; set; }
    public DbSet<TipoAsegurado> TiposAsegurado { get; set; }
    public DbSet<Empresa> Empresas { get; set; }
    public DbSet<EstadoCitaDb> EstadosCita { get; set; }

    // Identidad
    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Contacto> Contactos { get; set; }

    // Médicos
    public DbSet<Medico> Medicos { get; set; }
    public DbSet<ColegioMedico> ColegiosMedico { get; set; }
    public DbSet<MedicoEspecialidad> MedicoEspecialidades { get; set; }
    public DbSet<Tarifa> Tarifas { get; set; }

    // Pacientes
    public DbSet<Paciente> Pacientes { get; set; }
    public DbSet<Seguro> Seguros { get; set; }
    public DbSet<PacienteSeguro> PacienteSeguros { get; set; }

    // Citas
    public DbSet<Cita> Citas { get; set; }

    // Clínico
    public DbSet<Medicamento> Medicamentos { get; set; }
    public DbSet<Receta> Recetas { get; set; }
    public DbSet<DetalleReceta> DetallesReceta { get; set; }

    // Financiero
    public DbSet<Factura> Comprobantes { get; set; }

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

        modelBuilder.Entity<Cita>()
            .HasOne(c => c.EspecialidadNav)
            .WithMany()
            .HasForeignKey(c => c.IdEspecialidad)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Cita>()
            .HasOne(c => c.TarifaNav)
            .WithMany()
            .HasForeignKey(c => c.IdTarifa)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<Paciente>()
            .HasOne(p => p.Usuario)
            .WithOne()
            .HasForeignKey<Paciente>(p => p.IdUsuario);

        modelBuilder.Entity<Medico>()
            .HasOne(m => m.Usuario)
            .WithOne()
            .HasForeignKey<Medico>(m => m.IdUsuario);

        modelBuilder.Entity<Tarifa>()
            .HasOne(t => t.Medico)
            .WithMany(m => m.Tarifas)
            .HasForeignKey(t => t.IdMedico)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Tarifa>()
            .HasOne(t => t.Especialidad)
            .WithMany()
            .HasForeignKey(t => t.IdEspecialidad)
            .OnDelete(DeleteBehavior.Restrict);

        // Mapeo del EstadoCita: la tabla se llama EstadoCita (singular)
        modelBuilder.Entity<EstadoCitaDb>()
            .ToTable("EstadoCita")
            .HasKey(e => e.IdEstado);

        modelBuilder.Entity<EstadoCitaDb>()
            .Property(e => e.IdEstado)
            .HasColumnName("IdEstadoCita");
    }
}
