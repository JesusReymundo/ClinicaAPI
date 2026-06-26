using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("MedicoEspecialidad")]
public class MedicoEspecialidad
{
    [Key]
    public int IdMedicoEsp { get; set; }
    public int IdMedico { get; set; }
    public int IdEspecialidad { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
    public DateTime? FechaModificacion { get; set; }
    public int? IdUsuarioCreacion { get; set; }
    public int? IdUsuarioModificacion { get; set; }

    [ForeignKey("IdMedico")]
    public Medico? Medico { get; set; }
    [ForeignKey("IdEspecialidad")]
    public Especialidad? Especialidad { get; set; }
}
