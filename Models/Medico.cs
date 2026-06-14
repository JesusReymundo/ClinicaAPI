using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Medicos")]
public class Medico
{
    [Key]
    public int IdMedico { get; set; }
    public int IdUsuario { get; set; }
    public int IdEspecialidad { get; set; }
    [Required, MaxLength(20)]
    public string ColegioMedico { get; set; } = string.Empty;
    [MaxLength(50)]
    public string? Consultorio { get; set; }
    [Column(TypeName = "decimal(10,2)")]
    public decimal? TarifaConsulta { get; set; }
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    [ForeignKey("IdUsuario")]
    public Usuario? Usuario { get; set; }
    [ForeignKey("IdEspecialidad")]
    public Especialidad? EspecialidadNav { get; set; }
}
