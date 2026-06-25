using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Cita")]
public class Cita
{
    [Key]
    [Column("IdCita")]
    public int Id { get; set; }

    [Column("IdPaciente")]
    public int PacienteId { get; set; }

    [Column("IdMedico")]
    public int MedicoId { get; set; }

    public int IdEspecialidad { get; set; }
    public int? IdTarifa { get; set; }

    [Column("IdEstadoCita")]
    public int IdEstado { get; set; } = 1;

    [NotMapped]
    public EstadoCita Estado
    {
        get => (EstadoCita)IdEstado;
        set => IdEstado = (int)value;
    }

    [Required, MaxLength(300)]
    public string Motivo { get; set; } = string.Empty;

    public DateTime FechaHora { get; set; }

    [MaxLength(500)]
    public string? Observaciones { get; set; }

    public DateTime FechaCreacion { get; set; } = DateTime.Now;
    public DateTime? FechaModificacion { get; set; }
    public int? IdUsuarioCreacion { get; set; }
    public int? IdUsuarioModificacion { get; set; }

    [ForeignKey("PacienteId")]
    public Paciente? Paciente { get; set; }

    [ForeignKey("MedicoId")]
    public Medico? MedicoNav { get; set; }

    [ForeignKey("IdEstado")]
    public EstadoCitaDb? EstadoCitaNav { get; set; }

    [ForeignKey("IdEspecialidad")]
    public Especialidad? EspecialidadNav { get; set; }

    [ForeignKey("IdTarifa")]
    public Tarifa? TarifaNav { get; set; }
}
